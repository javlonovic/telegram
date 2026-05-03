from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404

from .models import Chat, ChatMember, GroupMeta
from .serializers import ChatSerializer, GroupMetaSerializer, ChatMemberSerializer
from apps.users.serializers import UserSerializer


class ChatListCreateView(generics.ListCreateAPIView):
    """GET /api/chats/  POST /api/chats/"""
    permission_classes = [IsAuthenticated]
    serializer_class = ChatSerializer

    def get_queryset(self):
        return (
            Chat.objects
            .filter(members=self.request.user)
            .prefetch_related('memberships__user', 'messages', 'group_meta')
            .order_by('-created_at')
        )

    def get_serializer_context(self):
        return {'request': self.request}


class ChatDetailView(generics.RetrieveAPIView):
    """GET /api/chats/<pk>/"""
    permission_classes = [IsAuthenticated]
    serializer_class = ChatSerializer

    def get_queryset(self):
        return Chat.objects.filter(members=self.request.user)

    def get_serializer_context(self):
        return {'request': self.request}


class GroupUpdateView(APIView):
    """PATCH /api/chats/<pk>/group/ — update group name/description/avatar"""
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def patch(self, request, pk):
        chat = get_object_or_404(Chat, pk=pk, members=request.user)
        membership = ChatMember.objects.filter(
            chat=chat, user=request.user,
            role__in=[ChatMember.Role.ADMIN, ChatMember.Role.OWNER]
        ).first()
        if not membership:
            return Response({'detail': 'Admin access required.'}, status=status.HTTP_403_FORBIDDEN)

        meta, _ = GroupMeta.objects.get_or_create(chat=chat, defaults={'name': f'Group {pk}'})
        serializer = GroupMetaSerializer(meta, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GroupMemberView(APIView):
    """POST   /api/chats/<pk>/members/     — add member
       DELETE /api/chats/<pk>/members/<uid>/ — remove member"""
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        chat = get_object_or_404(Chat, pk=pk, members=request.user)
        self._require_admin(chat, request.user)

        from django.contrib.auth import get_user_model
        User = get_user_model()
        user_id = request.data.get('user_id')
        user = get_object_or_404(User, pk=user_id)
        ChatMember.objects.get_or_create(chat=chat, user=user)
        return Response({'detail': f'{user.username} added.'})

    def delete(self, request, pk, uid):
        chat = get_object_or_404(Chat, pk=pk, members=request.user)
        self._require_admin(chat, request.user)
        ChatMember.objects.filter(chat=chat, user_id=uid).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    def _require_admin(self, chat, user):
        membership = ChatMember.objects.filter(
            chat=chat, user=user,
            role__in=[ChatMember.Role.ADMIN, ChatMember.Role.OWNER]
        ).first()
        if not membership:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied('Admin access required.')


class ReadReceiptView(APIView):
    """POST /api/chats/<pk>/read/ — mark messages as read up to message_id"""
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        from apps.messaging.models import Message, MessageReadReceipt

        chat = get_object_or_404(Chat, pk=pk, members=request.user)
        message_id = request.data.get('message_id')
        if not message_id:
            return Response({'detail': 'message_id required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Mark all unread messages up to message_id as read
        unread = Message.objects.filter(
            chat=chat,
            id__lte=message_id,
        ).exclude(
            read_receipts__user=request.user
        ).exclude(sender=request.user)

        receipts = [
            MessageReadReceipt(message=msg, user=request.user)
            for msg in unread
        ]
        MessageReadReceipt.objects.bulk_create(receipts, ignore_conflicts=True)

        # Update last_read on membership
        ChatMember.objects.filter(chat=chat, user=request.user).update(
            last_read_message_id=message_id
        )

        return Response({'detail': 'Marked as read.', 'count': len(receipts)})
