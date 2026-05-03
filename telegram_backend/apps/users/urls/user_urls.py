from django.urls import path
from apps.users.views import (
    user_search_view, UserDetailView, MeView,
    FCMTokenView, ContactListView, ContactDetailView,
)

urlpatterns = [
    path('', user_search_view, name='user-search'),
    path('me/', MeView.as_view(), name='user-me'),
    path('fcm-token/', FCMTokenView.as_view(), name='fcm-token'),
    path('contacts/', ContactListView.as_view(), name='contact-list'),
    path('contacts/<int:pk>/', ContactDetailView.as_view(), name='contact-detail'),
    path('<int:pk>/', UserDetailView.as_view(), name='user-detail'),
]
