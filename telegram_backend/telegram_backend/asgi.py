import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
import apps.messaging.routing as messaging_routing
import apps.users.routing as presence_routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'telegram_backend.settings')

application = ProtocolTypeRouter({
    'http': get_asgi_application(),
    'websocket': AuthMiddlewareStack(
        URLRouter(
            messaging_routing.websocket_urlpatterns +
            presence_routing.websocket_urlpatterns
        )
    ),
})
