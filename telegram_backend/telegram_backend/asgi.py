import os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'telegram_backend.settings')

from django.core.asgi import get_asgi_application

# Initialize Django app registry before importing anything that uses models
django_asgi_app = get_asgi_application()

from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
import apps.messaging.routing as messaging_routing
import apps.users.routing as presence_routing

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': AuthMiddlewareStack(
        URLRouter(
            messaging_routing.websocket_urlpatterns +
            presence_routing.websocket_urlpatterns
        )
    ),
})
