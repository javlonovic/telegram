from django.urls import path
from .views import chat_list_view, chat_detail_view

urlpatterns = [
    path('', chat_list_view, name='chat-list'),
    path('<int:pk>/', chat_detail_view, name='chat-detail'),
]
