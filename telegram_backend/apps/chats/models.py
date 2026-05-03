from django.db import models
from django.conf import settings


class Chat(models.Model):
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
        through='ChatMember',
        related_name='chats',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'chats'
        ordering = ['-created_at']

    def __str__(self):
        return f'Chat [{self.type}] #{self.id}'


class ChatMember(models.Model):
    """Through model — tracks role and read state per member."""
    class Role(models.TextChoices):
        MEMBER = 'member', 'Member'
        ADMIN = 'admin', 'Admin'
        OWNER = 'owner', 'Owner'

    chat = models.ForeignKey(Chat, on_delete=models.CASCADE, related_name='memberships')
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='chat_memberships',
    )
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.MEMBER)
    last_read_message = models.ForeignKey(
        'messaging.Message',
        null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name='+',
    )
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'chat_members'
        unique_together = ('chat', 'user')

    def __str__(self):
        return f'{self.user.username} in Chat #{self.chat_id} [{self.role}]'


class GroupMeta(models.Model):
    """Extra metadata for group/channel chats."""
    chat = models.OneToOneField(Chat, on_delete=models.CASCADE, related_name='group_meta')
    name = models.CharField(max_length=128)
    description = models.TextField(blank=True, default='')
    avatar = models.ImageField(upload_to='group_avatars/', blank=True, null=True)
    invite_link = models.CharField(max_length=64, unique=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'group_meta'

    def save(self, *args, **kwargs):
        if not self.invite_link:
            import secrets
            self.invite_link = secrets.token_urlsafe(16)
        super().save(*args, **kwargs)

    def __str__(self):
        return f'Group: {self.name}'
