from storages.backends.s3boto3 import S3Boto3Storage
from django.conf import settings


class MediaStorage(S3Boto3Storage):
    location = settings.AWS_DEFAULT_STORAGE_FOLDER
    default_acl = 'public-read'
    file_overwrite = False
