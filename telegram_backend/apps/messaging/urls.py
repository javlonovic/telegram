from django.urls import path
from .views import message_list_view

urlpatterns = [
    path('', message_list_view, name='message-list'),
]
