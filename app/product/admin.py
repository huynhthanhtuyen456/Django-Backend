from django.contrib import admin

# Register your models here.
from app.product.models import Product


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('cost', 'title', 'sale_of', 'product_image', 'product_external_id')
