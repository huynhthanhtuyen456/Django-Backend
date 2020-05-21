import uuid

from app.core.storage_backends import MediaStorage
from app.core.utils import storage_path
from django.db import models
from django.utils.datetime_safe import datetime
from model_utils.models import TimeStampedModel
# Create your models here.


class Product(TimeStampedModel):

    def product_images_path(self, filename, *args, **kwargs):
        now = datetime.now()
        folder = '/'.join(['product', str(now.year), str(now.month), str(now.day), 'images'])
        return storage_path(folder, filename)

    cost = models.FloatField(default=0)
    sale_of = models.FloatField(default=0)
    title = models.TextField(blank=True, null=True)
    product_image = models.ImageField(storage=MediaStorage(), upload_to=product_images_path, blank=True, null=True)
    product_external_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    def __str__(self):
        return self.title
