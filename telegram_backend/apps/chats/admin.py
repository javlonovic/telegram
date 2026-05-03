from django.contrib import admin
from .models import Chat, ChatMember, GroupMeta


class ChatMemberInline(admin.TabularInline):
    model = ChatMember
    extra = 0
    fields = ('user', 'role', 'joined_at')
    readonly_fields = ('joined_at',)


@admin.register(Chat)
class ChatAdmin(admin.ModelAdmin):
    list_display = ('id', 'type', 'created_at')
    list_filter = ('type',)
    inlines = [ChatMemberInline]


@admin.register(ChatMember)
class ChatMemberAdmin(admin.ModelAdmin):
    list_display = ('chat', 'user', 'role', 'joined_at')
    list_filter = ('role',)
    search_fields = ('user__username', 'chat__id')


@admin.register(GroupMeta)
class GroupMetaAdmin(admin.ModelAdmin):
    list_display = ('name', 'chat', 'created_at')
    search_fields = ('name',)
