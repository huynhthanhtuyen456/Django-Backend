from django.urls import path

from . import views

urlpatterns = [
    path('me/', views.UserProfileView.as_view(), name='me'),
    path('profile/', views.UpdateUserProfileView.as_view(), name='update-profile'),
    path('exists/', views.UserExistView.as_view(), name='user-exists'),
]
