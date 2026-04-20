from django.db import models
from django.conf import settings


class Message(models.Model):
    """
    A single message within a chat.
    """
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
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'messages'
        ordering = ['created_at']

    def __str__(self):
        return f'Message #{self.id} in Chat #{self.chat_id}'
