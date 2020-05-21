from rest_framework import serializers
from rest_auth.registration.serializers import RegisterSerializer as RestAuthRegisterSerializer
from rest_auth.serializers import PasswordResetSerializer as RestAuthPasswordResetSerializer

from .models import *


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('user_id', 'email', 'first_name', 'last_name', )


class RegisterSerializer(RestAuthRegisterSerializer):
    first_name = serializers.CharField(max_length=30, required=False, default=None)
    last_name = serializers.CharField(max_length=150, required=False, default=None)

    def get_cleaned_data(self):
        clean_data = super().get_cleaned_data()
        clean_data.update({
            'first_name': self.validated_data.get('first_name', None),
            'last_name': self.validated_data.get('last_name', None)
        })
        return clean_data


class PasswordResetSerializer(RestAuthPasswordResetSerializer):

    def validate_email(self, value):
        value = super(PasswordResetSerializer, self).validate_email(value)
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError(
                "This e-mail address does not exist.")
        return value

    def get_email_options(self):
        return {
            'subject_template_name': 'registration/password_reset_subject.txt',
            'email_template_name': 'registration/password_reset_email.html',
        }

