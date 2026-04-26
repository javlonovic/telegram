from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Chat
from .serializers import ChatSerializer


class ChatListCreateView(generics.ListCreateAPIView):
    """GET /api/chats/  — list user's chats
       POST /api/chats/ — create a new chat"""
    permission_classes = [IsAuthenticated]
    serializer_class = ChatSerializer

    def get_queryset(self):
        return (
            Chat.objects
            .filter(members=self.request.user)
            .prefetch_related('members', 'messages')
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
