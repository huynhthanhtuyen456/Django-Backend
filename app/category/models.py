from django.db import models
from django.utils.datetime_safe import datetime
from model_utils.models import TimeStampedModel
# Create your models here.
from app.core.storage_backends import MediaStorage
from app.core.utils import storage_path
from app.product.models import Product


class Category(TimeStampedModel):

    def category_images_path(self, filename, *args, **kwargs):
        now = datetime.now()
        folder = '/'.join(['category', str(now.year), str(now.month), str(now.day), 'images'])
        return storage_path(folder, filename)

    name = models.CharField(max_length=255, blank=True, null=True)
    key = models.CharField(max_length=255, blank=True, null=True)
    product_image = models.ImageField(storage=MediaStorage(), upload_to=category_images_path, blank=True, null=True)

    class Meta:
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'

    def __str__(self):
        return self.name


class CategoryManager(TimeStampedModel):
    category_id = models.ForeignKey(Category, null=False, blank=False, on_delete=models.CASCADE)

    class Meta:
        verbose_name = 'Category Manager'
        verbose_name_plural = 'Category Manager'


class ProductCategory(TimeStampedModel):
    category_id = models.ForeignKey(Category, null=False, blank=False, on_delete=models.CASCADE)
    name = models.CharField(max_length=255, blank=True, null=True)
    key = models.CharField(max_length=255, blank=True, null=True)
    product_id_external = models.ForeignKey(Product, null=False, blank=False, on_delete=models.CASCADE)

    class Meta:
        verbose_name = 'Product Category'
        verbose_name_plural = 'Product Categories'

    def __str__(self):
        return self.name
