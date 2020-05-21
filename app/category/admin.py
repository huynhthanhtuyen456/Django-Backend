from django.contrib import admin

# Register your models here.
from app.category.models import Category, CategoryManager, ProductCategory


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'key', 'name')


@admin.register(CategoryManager)
class CategoryManagerAdmin(admin.ModelAdmin):
    list_display = ('id', 'category_id')


@admin.register(ProductCategory)
class ProductCategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'key', 'name', 'category_id', 'product_id_external')
