import os
from django.db import models
from django.conf import settings


def message_media_path(instance, filename):
    """Organizes uploads by chat: media/chats/<chat_id>/<filename>"""
    return os.path.join('media', 'chats', str(instance.chat_id), filename)


class Message(models.Model):
    class MessageType(models.TextChoices):
        TEXT = 'text', 'Text'
        IMAGE = 'image', 'Image'
        FILE = 'file', 'File'
        AUDIO = 'audio', 'Audio'
        VIDEO = 'video', 'Video'

    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='sent_messages',
    )
    chat = models.ForeignKey(
        'chats.Chat',
        on_delete=models.CASCADE,
        related_name='messages',
    )
    content = models.TextField(blank=True, default='')
    message_type = models.CharField(
        max_length=10,
        choices=MessageType.choices,
        default=MessageType.TEXT,
    )
    # Media fields
    media_file = models.FileField(
        upload_to=message_media_path,
        blank=True,
        null=True,
    )
    media_mime_type = models.CharField(max_length=100, blank=True, default='')
    media_file_name = models.CharField(max_length=255, blank=True, default='')
    media_file_size = models.PositiveBigIntegerField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'messages'
        ordering = ['created_at']

    def __str__(self):
        return f'Message #{self.id} [{self.message_type}] in Chat #{self.chat_id}'

    @property
    def media_url(self):
        if self.media_file:
            return self.media_file.url
        return None
