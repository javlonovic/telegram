"""
Firebase Cloud Messaging service.
Initializes the Firebase Admin SDK once and exposes send helpers.
"""
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

_initialized = False


def _init_firebase():
    """Lazy-initialize Firebase Admin SDK."""
    global _initialized
    if _initialized:
        return

    try:
        import firebase_admin
        from firebase_admin import credentials
        from django.conf import settings

        cred_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
        if not cred_path or not Path(cred_path).exists():
            logger.warning(
                'Firebase credentials not found at %s. '
                'Push notifications are disabled.',
                cred_path,
            )
            return

        if not firebase_admin._apps:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)

        _initialized = True
    except Exception as e:
        logger.error('Firebase init failed: %s', e)


def send_message_notification(
    *,
    fcm_token: str,
    sender_name: str,
    message_preview: str,
    chat_id: int,
    message_type: str = 'text',
) -> bool:
    """
    Send a push notification for a new chat message.
    Returns True on success, False on failure.
    """
    if not fcm_token:
        return False

    _init_firebase()
    if not _initialized:
        return False

    try:
        from firebase_admin import messaging

        # Notification body — truncate long messages
        body = message_preview[:100] if message_type == 'text' else f'Sent a {message_type}'

        message = messaging.Message(
            notification=messaging.Notification(
                title=sender_name,
                body=body,
            ),
            data={
                'chat_id': str(chat_id),
                'message_type': message_type,
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default',
                    channel_id='messages',
                    priority='high',
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound='default', badge=1),
                ),
            ),
            token=fcm_token,
        )

        messaging.send(message)
        return True

    except Exception as e:
        logger.error('FCM send failed for token %s: %s', fcm_token[:20], e)
        return False


def send_bulk_notifications(
    *,
    tokens: list[str],
    sender_name: str,
    message_preview: str,
    chat_id: int,
    message_type: str = 'text',
) -> dict:
    """
    Send notifications to multiple tokens (e.g. group chat members).
    Returns {'success': int, 'failure': int}.
    """
    if not tokens:
        return {'success': 0, 'failure': 0}

    _init_firebase()
    if not _initialized:
        return {'success': 0, 'failure': len(tokens)}

    try:
        from firebase_admin import messaging

        body = message_preview[:100] if message_type == 'text' else f'Sent a {message_type}'

        messages = [
            messaging.Message(
                notification=messaging.Notification(
                    title=sender_name,
                    body=body,
                ),
                data={
                    'chat_id': str(chat_id),
                    'message_type': message_type,
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                },
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        sound='default',
                        channel_id='messages',
                    ),
                ),
                token=token,
            )
            for token in tokens
        ]

        response = messaging.send_each(messages)
        return {
            'success': response.success_count,
            'failure': response.failure_count,
        }

    except Exception as e:
        logger.error('FCM bulk send failed: %s', e)
        return {'success': 0, 'failure': len(tokens)}
