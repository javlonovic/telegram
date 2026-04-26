from rest_framework import serializers
from .models import Message
from apps.users.serializers import UserSerializer


class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    sender_id = serializers.IntegerField(read_only=True, source='sender.id')
    media_url = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = (
            'id', 'sender', 'sender_id', 'chat',
            'content', 'message_type',
            'media_url', 'media_file_name', 'media_file_size', 'media_mime_type',
            'created_at',
        )
        read_only_fields = (
            'id', 'sender', 'sender_id', 'created_at',
            'media_url', 'media_file_name', 'media_file_size', 'media_mime_type',
        )

    def get_media_url(self, obj):
        request = self.context.get('request')
        if obj.media_file and request:
            return request.build_absolute_uri(obj.media_url)
        return obj.media_url

    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['sender'] = request.user
        return super().create(validated_data)


class MediaUploadSerializer(serializers.Serializer):
    """Handles multipart file upload for a chat message."""
    chat = serializers.IntegerField()
    file = serializers.FileField()
    caption = serializers.CharField(required=False, allow_blank=True, default='')
