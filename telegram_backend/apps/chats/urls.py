from django.urls import path
from .views import (
    ChatListCreateView, ChatDetailView,
    GroupUpdateView, GroupMemberView, ReadReceiptView,
    DeduplicateChatsView,
)

urlpatterns = [
    path('', ChatListCreateView.as_view(), name='chat-list'),
    path('deduplicate/', DeduplicateChatsView.as_view(), name='chat-deduplicate'),
    path('<int:pk>/', ChatDetailView.as_view(), name='chat-detail'),
    path('<int:pk>/group/', GroupUpdateView.as_view(), name='group-update'),
    path('<int:pk>/members/', GroupMemberView.as_view(), name='group-member-add'),
    path('<int:pk>/members/<int:uid>/', GroupMemberView.as_view(), name='group-member-remove'),
    path('<int:pk>/read/', ReadReceiptView.as_view(), name='read-receipt'),
]
