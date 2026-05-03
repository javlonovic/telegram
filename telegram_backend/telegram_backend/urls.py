from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse

def health(request):
    return JsonResponse({'status': 'ok'})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/health/', health),

    # API v1
    path('api/auth/', include('apps.users.urls.auth_urls')),
    path('api/users/', include('apps.users.urls.user_urls')),
    path('api/chats/', include('apps.chats.urls')),
    path('api/messages/', include('apps.messaging.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
