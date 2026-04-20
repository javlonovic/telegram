from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(['GET'])
def message_list_view(request):
    """GET /api/messages/"""
    return Response(
        {'message': 'Messages endpoint ready', 'messages': []},
        status=status.HTTP_200_OK,
    )
