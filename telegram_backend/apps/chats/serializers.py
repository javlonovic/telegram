from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Chat, ChatMember, GroupMeta
from apps.users.serializers import UserSerializer

User = get_user_model()


class GroupMetaSerializer(serializers.ModelSerializer):
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = GroupMeta
        fields = ('name', 'description', 'avatar_url', 'invite_link')
        read_only_fields = ('invite_link',)

    def get_avatar_url(self, obj):
        request = self.context.get('request')
        if obj.avatar and request:
            return request.build_absolute_uri(obj.avatar.url)
        return None


class ChatMemberSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = ChatMember
        fields = ('user', 'role', 'joined_at')


class ChatSerializer(serializers.ModelSerializer):
    members = ChatMemberSerializer(source='memberships', many=True, read_only=True)
    member_ids = serializers.PrimaryKeyRelatedField(
        many=True, write_only=True,
        queryset=User.objects.all(), source='members_input',
    )
    group_meta = GroupMetaSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Chat
        fields = (
            'id', 'type', 'members', 'member_ids',
            'group_meta', 'last_message', 'unread_count', 'created_at',
        )
        read_only_fields = ('id', 'created_at')

    def get_last_message(self, obj):
        from apps.messaging.serializers import MessageSerializer
        last = obj.messages.order_by('-created_at').first()
        return MessageSerializer(last, context=self.context).data if last else None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not request:
            return 0
        membership = obj.memberships.filter(user=request.user).first()
        if not membership or not membership.last_read_message:
            return obj.messages.count()
        return obj.messages.filter(
            id__gt=membership.last_read_message_id
        ).count()

    def create(self, validated_data):
        members_input = validated_data.pop('members_input', [])
        group_name = self.initial_data.get('group_name', '')
        request = self.context.get('request')

        chat = Chat.objects.create(**validated_data)

        # Add creator as owner
        ChatMember.objects.create(chat=chat, user=request.user, role=ChatMember.Role.OWNER)

        # Add other members
        for user in members_input:
            if user != request.user:
                ChatMember.objects.get_or_create(chat=chat, user=user)

        # Create group meta for non-private chats
        if chat.type != Chat.ChatType.PRIVATE and group_name:
            GroupMeta.objects.create(chat=chat, name=group_name)

        return chat
