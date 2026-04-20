from django.urls import path
from apps.users.views import user_list_view, UserDetailView, MeView

urlpatterns = [
    path('', user_list_view, name='user-list'),
    path('me/', MeView.as_view(), name='user-me'),
    path('<int:pk>/', UserDetailView.as_view(), name='user-detail'),
]
