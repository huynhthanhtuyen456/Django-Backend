from .exceptions import MissedUsernameOrEmailException
from .models import User


def exists_user(username=None, email=None):
    if not username and not email:
        raise MissedUsernameOrEmailException()
    if username:
        queryset = User.objects.filter(username__iexact=username)
    else:
        queryset = User.objects.filter(email__iexact=email)
    count = queryset.count()
    return count > 0


