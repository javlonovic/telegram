from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from django.channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
import json

from .models import Message
from .serializers import MessageSerializer, MediaUploadSerializer
from .utils.file_validator import validate_upload, mime_to_message_type
from apps.chats.models import Chat


class MessageListView(generics.ListAPIView):
    """GET /api/messages/?chat=<id>"""
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        chat_id = self.request.query_params.get('chat')
        if not chat_id:
            return Message.objects.none()
        return (
            Message.objects
            .filter(chat_id=chat_id, chat__members=self.request.user)
            .select_related('sender')
            .order_by('created_at')
        )

    def get_serializer_context(self):
        return {'request': self.request}


class MediaUploadView(APIView):
    """
    POST /api/messages/upload/
    Accepts multipart/form-data with 'file' and 'chat' fields.
    Saves the file, creates a Message, and broadcasts via Channels.
    """
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        serializer = MediaUploadSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        chat_id = serializer.validated_data['chat']
        file = serializer.validated_data['file']
        caption = serializer.validated_data.get('caption', '')

        # Verify user is a member of the chat
        try:
            chat = Chat.objects.get(id=chat_id, members=request.user)
        except Chat.DoesNotExist:
            return Response(
                {'detail': 'Chat not found or access denied.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        # Validate file
        mime_type = validate_upload(file)
        msg_type = mime_to_message_type(mime_type)

        # Create message with media
        message = Message.objects.create(
            sender=request.user,
            chat=chat,
            content=caption,
            message_type=msg_type,
            media_file=file,
            media_mime_type=mime_type,
            media_file_name=file.name,
            media_file_size=file.size,
        )

        # Broadcast to WebSocket group
        self._broadcast(message, request)
        self._send_notifications(message, chat)

        msg_serializer = MessageSerializer(message, context={'request': request})
        return Response(msg_serializer.data, status=status.HTTP_201_CREATED)

    def _broadcast(self, message, request):
        """Push the new media message to all WebSocket clients in the chat."""
        try:
            channel_layer = get_channel_layer()
            room = f'chat_{message.chat_id}'
            payload = {
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
                'media_url': request.build_absolute_uri(message.media_url) if message.media_url else None,
                'media_file_name': message.media_file_name,
                'media_file_size': message.media_file_size,
                'media_mime_type': message.media_mime_type,
                'created_at': message.created_at.isoformat(),
            }
            async_to_sync(channel_layer.group_send)(
                room, {'type': 'chat_message', 'message': payload}
            )
        except Exception:
            pass  # Don't fail the upload if broadcast fails

    def _send_notifications(self, message, chat):
        """FCM push to offline members after media upload."""
        try:
            from telegram_backend.firebase.fcm_service import send_bulk_notifications
            tokens = [
                m.fcm_token
                for m in chat.members.all()
                if m.id != message.sender.id and m.fcm_token
            ]
            if tokens:
                send_bulk_notifications(
                    tokens=tokens,
                    sender_name=message.sender.username,
                    message_preview=message.content or message.media_file_name or '',
                    chat_id=chat.id,
                    message_type=message.message_type,
                )
        except Exception:
            pass
