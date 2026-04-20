from django.db import models
from django.conf import settings


class Chat(models.Model):
    """
    Represents a conversation — private, group, or channel.
    """
    class ChatType(models.TextChoices):
        PRIVATE = 'private', 'Private'
        GROUP = 'group', 'Group'
        CHANNEL = 'channel', 'Channel'

    type = models.CharField(
        max_length=10,
        choices=ChatType.choices,
        default=ChatType.PRIVATE,
    )
    members = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='chats',
        blank=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'chats'
        ordering = ['-created_at']

    def __str__(self):
        return f'Chat [{self.type}] #{self.id}'
