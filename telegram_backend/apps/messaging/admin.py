from django.contrib import admin
from .models import Message


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('id', 'sender', 'chat', 'message_type', 'created_at')
    list_filter = ('message_type',)
    search_fields = ('content', 'sender__username')
    ordering = ('-created_at',)
