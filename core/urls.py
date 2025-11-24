"""
URL configuration for core app.
"""
from django.urls import path
from django.contrib.auth.views import (
    LogoutView, PasswordResetDoneView,
    PasswordResetConfirmView, PasswordResetCompleteView
)
from . import views

urlpatterns = [
    # Placeholder
]
