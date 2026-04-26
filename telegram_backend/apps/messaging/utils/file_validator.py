import os
from django.conf import settings
from rest_framework.exceptions import ValidationError


def validate_upload(file) -> str:
    """
    Validates size and MIME type of an uploaded file.
    Returns the detected MIME type string.
    Raises ValidationError on failure.
    """
    # Size check
    if file.size > settings.MAX_UPLOAD_SIZE_BYTES:
        max_mb = settings.MAX_UPLOAD_SIZE_BYTES // (1024 * 1024)
        raise ValidationError(f'File too large. Maximum size is {max_mb} MB.')

    # MIME type check via python-magic (reads file header bytes)
    try:
        import magic
        mime = magic.from_buffer(file.read(2048), mime=True)
        file.seek(0)  # Reset after reading header
    except ImportError:
        # Fallback to extension-based check if python-magic not available
        ext = os.path.splitext(file.name)[1].lower()
        ext_map = {
            '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
            '.png': 'image/png', '.gif': 'image/gif',
            '.webp': 'image/webp', '.pdf': 'application/pdf',
            '.mp4': 'video/mp4', '.mp3': 'audio/mpeg',
            '.ogg': 'audio/ogg', '.zip': 'application/zip',
        }
        mime = ext_map.get(ext, 'application/octet-stream')

    if mime not in settings.ALLOWED_FILE_TYPES:
        raise ValidationError(f'File type "{mime}" is not allowed.')

    return mime


def mime_to_message_type(mime: str) -> str:
    """Maps MIME type to Message.MessageType choice."""
    if mime.startswith('image/'):
        return 'image'
    if mime.startswith('video/'):
        return 'video'
    if mime.startswith('audio/'):
        return 'audio'
    return 'file'
