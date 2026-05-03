import os
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    def create_user(self, phone, username, password=None, **extra_fields):
        if not phone:
            raise ValueError('Phone number is required')
        user = self.model(phone=phone, username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(phone, username, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Custom user — phone is the primary identifier."""
    username = models.CharField(max_length=64, unique=True)
    phone = models.CharField(max_length=20, unique=True)
    bio = models.TextField(blank=True, default='')
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    fcm_token = models.TextField(blank=True, default='')
    is_online = models.BooleanField(default=False)
    last_seen = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']

    def __str__(self):
        return f'@{self.username} ({self.phone})'


class Contact(models.Model):
    """A user's saved contact list entry."""
    owner = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='contacts'
    )
    contact = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='contact_of'
    )
    nickname = models.CharField(max_length=64, blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'contacts'
        unique_together = ('owner', 'contact')
        ordering = ['contact__username']

    def __str__(self):
        return f'{self.owner.username} → {self.contact.username}'
