from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(['GET'])
def chat_list_view(request):
    """GET /api/chats/"""
    return Response(
        {'message': 'Chats endpoint ready', 'chats': []},
        status=status.HTTP_200_OK,
    )


@api_view(['GET'])
def chat_detail_view(request, pk):
    """GET /api/chats/<pk>/"""
    return Response(
        {'message': f'Chat {pk} endpoint ready'},
        status=status.HTTP_200_OK,
    )
