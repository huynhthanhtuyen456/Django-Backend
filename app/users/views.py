from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from drf_yasg.utils import swagger_auto_schema

from . import serializers
from . import services


class UserProfileView(generics.RetrieveAPIView):
    serializer_class = serializers.UserSerializer

    def get_object(self):
        return self.request.user


class UpdateUserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = serializers.UserSerializer

    def get_object(self):
        return self.request.user


class UserExistView(APIView):
    permission_classes = (AllowAny,)

    @swagger_auto_schema(
        operation_summary='check exist email or username',
        operation_id='username_email_exist',
        security=[]
    )
    def get(self, request, *args, **kwargs):
        username = request.query_params.get('username')
        email = request.query_params.get('email')

        exists = services.exists_user(username=username, email=email)
        data = {'exists': exists}
        return Response(data, status=status.HTTP_200_OK)

