from rest_framework import serializers
from .models import Chat
from apps.users.serializers import UserSerializer


class ChatSerializer(serializers.ModelSerializer):
    members = UserSerializer(many=True, read_only=True)
    member_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        write_only=True,
        source='members',
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.all(),
    )
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Chat
        fields = ('id', 'type', 'members', 'member_ids', 'last_message', 'unread_count', 'created_at')
        read_only_fields = ('id', 'created_at')

    def get_last_message(self, obj):
        from apps.messaging.serializers import MessageSerializer
        last = obj.messages.order_by('-created_at').first()
        if last:
            return MessageSerializer(last).data
        return None

    def get_unread_count(self, obj):
        # Placeholder — will be implemented with read receipts in Phase 6
        return 0

    def create(self, validated_data):
        members = validated_data.pop('members', [])
        request = self.context.get('request')
        chat = Chat.objects.create(**validated_data)
        chat.members.set(members)
        # Always include the creator
        if request and request.user not in members:
            chat.members.add(request.user)
        return chat
