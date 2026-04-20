"""
ASGI config — handles both HTTP (Django) and WebSocket (Channels) connections.
"""
import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
import apps.messaging.routing as messaging_routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'telegram_backend.settings')

application = ProtocolTypeRouter({
    # Standard HTTP requests handled by Django
    'http': get_asgi_application(),

    # WebSocket connections routed through Channels
    'websocket': AuthMiddlewareStack(
        URLRouter(
            messaging_routing.websocket_urlpatterns
        )
    ),
})
