from app.core.exceptions import GenericException


class MissedUsernameOrEmailException(GenericException):
    code = 'missed_username_or_email'
    verbose = True

    def __init__(self, message=None):
        if not message:
            message = 'Username or email is required'
        super().__init__(message=message)
