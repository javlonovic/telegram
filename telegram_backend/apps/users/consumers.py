"""
Presence WebSocket consumer.
URL: ws://host/ws/presence/?token=<jwt>

Clients connect on app open and disconnect on app close.
Broadcasts online/offline status to all connected clients.
"""
import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework_simplejwt.tokens import AccessToken

logger = logging.getLogger(__name__)
User = get_user_model()

PRESENCE_GROUP = 'presence'


class PresenceConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        self.user = await self.get_user_from_token()
        if not self.user:
            await self.close(code=4001)
            return

        await self.channel_layer.group_add(PRESENCE_GROUP, self.channel_name)
        await self.set_online(True)
        await self.accept()

        # Broadcast this user came online
        await self.channel_layer.group_send(
            PRESENCE_GROUP,
            {
                'type': 'presence_update',
                'user_id': self.user.id,
                'is_online': True,
            },
        )

    async def disconnect(self, close_code):
        if not hasattr(self, 'user') or not self.user:
            return
        await self.set_online(False)
        await self.channel_layer.group_send(
            PRESENCE_GROUP,
            {
                'type': 'presence_update',
                'user_id': self.user.id,
                'is_online': False,
                'last_seen': timezone.now().isoformat(),
            },
        )
        await self.channel_layer.group_discard(PRESENCE_GROUP, self.channel_name)

    async def presence_update(self, event):
        await self.send(text_data=json.dumps({
            'type': 'presence',
            'user_id': event['user_id'],
            'is_online': event['is_online'],
            'last_seen': event.get('last_seen'),
        }))

    @database_sync_to_async
    def get_user_from_token(self):
        try:
            token_str = self.scope['query_string'].decode().split('token=')[-1]
            access_token = AccessToken(token_str)
            return User.objects.get(id=access_token['user_id'])
        except Exception:
            return None

    @database_sync_to_async
    def set_online(self, is_online: bool):
        User.objects.filter(id=self.user.id).update(
            is_online=is_online,
            last_seen=timezone.now() if not is_online else None,
        )
