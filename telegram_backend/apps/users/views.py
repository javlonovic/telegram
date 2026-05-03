from django.contrib.auth import get_user_model, authenticate
from django.db.models import Q
from django.utils import timezone
from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Contact
from .serializers import (
    RegisterSerializer, UserSerializer,
    UpdateProfileSerializer, ContactSerializer,
)

User = get_user_model()


def _token_response(user):
    refresh = RefreshToken.for_user(user)
    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'user': UserSerializer(user).data,
    }


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(_token_response(user), status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        phone = request.data.get('phone', '').strip()
        password = request.data.get('password', '')
        if not phone or not password:
            return Response(
                {'detail': 'Phone and password are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user = authenticate(request, username=phone, password=password)
        if user is None:
            return Response(
                {'detail': 'Invalid credentials.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        # Mark online
        user.is_online = True
        user.save(update_fields=['is_online'])
        return Response(_token_response(user), status=status.HTTP_200_OK)


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            token = RefreshToken(request.data.get('refresh'))
            token.blacklist()
        except Exception:
            pass
        # Mark offline
        request.user.is_online = False
        request.user.last_seen = timezone.now()
        request.user.save(update_fields=['is_online', 'last_seen'])
        return Response({'detail': 'Logged out.'})


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------

class MeView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return UpdateProfileSerializer
        return UserSerializer

    def get_object(self):
        return self.request.user

    def get_serializer_context(self):
        return {'request': self.request}


class UserDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer
    queryset = User.objects.all()

    def get_serializer_context(self):
        return {'request': self.request}


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_search_view(request):
    """GET /api/users/?q=<query> — search by username or phone."""
    query = request.query_params.get('q', '').strip()
    if not query or len(query) < 2:
        return Response({'users': []})
    users = User.objects.filter(
        Q(username__icontains=query) | Q(phone__icontains=query)
    ).exclude(id=request.user.id)[:20]
    serializer = UserSerializer(users, many=True, context={'request': request})
    return Response({'users': serializer.data})


# ---------------------------------------------------------------------------
# Contacts
# ---------------------------------------------------------------------------

class ContactListView(generics.ListCreateAPIView):
    """GET /api/users/contacts/  — list contacts
       POST /api/users/contacts/ — add contact"""
    permission_classes = [IsAuthenticated]
    serializer_class = ContactSerializer

    def get_queryset(self):
        return Contact.objects.filter(owner=self.request.user).select_related('contact')

    def get_serializer_context(self):
        return {'request': self.request}


class ContactDetailView(generics.DestroyAPIView):
    """DELETE /api/users/contacts/<pk>/"""
    permission_classes = [IsAuthenticated]
    serializer_class = ContactSerializer

    def get_queryset(self):
        return Contact.objects.filter(owner=self.request.user)


# ---------------------------------------------------------------------------
# FCM Token
# ---------------------------------------------------------------------------

class FCMTokenView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        token = request.data.get('fcm_token', '').strip()
        if not token:
            return Response({'detail': 'fcm_token is required.'}, status=status.HTTP_400_BAD_REQUEST)
        request.user.fcm_token = token
        request.user.save(update_fields=['fcm_token'])
        return Response({'detail': 'FCM token updated.'})

    def delete(self, request):
        request.user.fcm_token = ''
        request.user.save(update_fields=['fcm_token'])
        return Response({'detail': 'FCM token cleared.'})
