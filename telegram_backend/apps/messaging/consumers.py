import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import AccessToken
from .models import Message
from apps.chats.models import Chat

logger = logging.getLogger(__name__)
User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for real-time messaging.
    URL: ws://host/ws/chat/<chat_id>/?token=<jwt_access_token>
    """

    async def connect(self):
        self.chat_id = self.scope['url_route']['kwargs']['chat_id']
        self.room_group_name = f'chat_{self.chat_id}'

        self.user = await self.get_user_from_token()
        if not self.user:
            await self.close(code=4001)
            return

        is_member = await self.is_chat_member()
        if not is_member:
            await self.close(code=4003)
            return

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name, self.channel_name
            )

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            message_type = data.get('type', 'text')
            content = data.get('content', '')

            if not content.strip():
                return

            message = await self.save_message(content, message_type)
            payload = await self.message_to_dict(message)

            # Broadcast to room
            await self.channel_layer.group_send(
                self.room_group_name,
                {'type': 'chat_message', 'message': payload},
            )

            # Push notifications to offline members (non-blocking)
            await self.notify_members(message)

        except Exception as e:
            logger.error('Consumer receive error: %s', e)
            await self.send(text_data=json.dumps({'error': str(e)}))

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event['message']))

    # ------------------------------------------------------------------
    # DB helpers
    # ------------------------------------------------------------------

    @database_sync_to_async
    def get_user_from_token(self):
        try:
            token_str = self.scope['query_string'].decode().split('token=')[-1]
            access_token = AccessToken(token_str)
            return User.objects.get(id=access_token['user_id'])
        except Exception:
            return None

    @database_sync_to_async
    def is_chat_member(self):
        try:
            chat = Chat.objects.get(id=self.chat_id)
            return chat.members.filter(id=self.user.id).exists()
        except Chat.DoesNotExist:
            return False

    @database_sync_to_async
    def save_message(self, content, message_type):
        return Message.objects.create(
            sender=self.user,
            chat_id=self.chat_id,
            content=content,
            message_type=message_type,
        )

    @database_sync_to_async
    def message_to_dict(self, message):
        return {
            'id': message.id,
            'sender': {
                'id': message.sender.id,
                'username': message.sender.username,
                'phone': message.sender.phone,
                'avatar_url': None,
            },
            'chat': message.chat_id,
            'content': message.content,
            'message_type': message.message_type,
            'media_url': message.media_url,
            'media_file_name': message.media_file_name,
            'media_file_size': message.media_file_size,
            'media_mime_type': message.media_mime_type,
            'created_at': message.created_at.isoformat(),
        }

    @database_sync_to_async
    def notify_members(self, message):
        """Send FCM push to all chat members except the sender."""
        try:
            from telegram_backend.firebase.fcm_service import send_bulk_notifications

            chat = Chat.objects.prefetch_related('members').get(id=self.chat_id)
            tokens = [
                m.fcm_token
                for m in chat.members.all()
                if m.id != self.user.id and m.fcm_token
            ]

            if tokens:
                send_bulk_notifications(
                    tokens=tokens,
                    sender_name=self.user.username,
                    message_preview=message.content,
                    chat_id=self.chat_id,
                    message_type=message.message_type,
                )
        except Exception as e:
            logger.error('Notification dispatch failed: %s', e)
