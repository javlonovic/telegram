from django.urls import path
from .views import MessageListView, MediaUploadView

urlpatterns = [
    path('', MessageListView.as_view(), name='message-list'),
    path('upload/', MediaUploadView.as_view(), name='media-upload'),
]
