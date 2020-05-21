import uuid

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.datetime_safe import datetime
from model_utils.models import TimeStampedModel

from app.core.storage_backends import MediaStorage
from app.core.utils import storage_path


class User(AbstractUser):

    def user_images_path(self, filename, *args, **kwargs):
        now = datetime.now()
        folder = '/'.join(['user_profile', str(now.year), str(now.month), str(now.day), 'images'])
        return storage_path(folder, filename)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    avatar = models.ImageField(storage=MediaStorage(), upload_to=user_images_path, blank=True, null=True)
    is_manager = models.BooleanField(default=False)

    def __str__(self):
        return self.name

    @property
    def name(self):
        name = "%s %s" % (self.first_name, self.last_name)
        if not name.strip():
            name = "User #%s" % self.pk
        return name

    def save(self, *args, **kwargs):
        if not self.pk and not self.username:
            from allauth.utils import generate_unique_username
            self.username = generate_unique_username(
                [self.first_name, self.last_name, self.email, self.username, 'user']
            )

        self.first_name = ' '.join(self.first_name.split())
        self.last_name = ' '.join(self.last_name.split())

        return super().save(*args, **kwargs)
