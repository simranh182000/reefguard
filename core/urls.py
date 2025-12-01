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
    # Home
    path('', views.HomeView.as_view(), name='home'),

    # Reefs
    path('reefs/', views.ReefListView.as_view(), name='reef_list'),
    path('reefs/<int:pk>/', views.ReefDetailView.as_view(), name='reef_detail'),

    # Events
    path('events/', views.EventListView.as_view(), name='event_list'),
    path('events/<int:pk>/', views.EventDetailView.as_view(), name='event_detail'),

    # Articles
    path('articles/', views.ArticleListView.as_view(), name='article_list'),
    path('articles/<slug:slug>/', views.ArticleDetailView.as_view(), name='article_detail'),

    # Forms
    path('report-pollution/', views.PollutionReportCreateView.as_view(), name='report_pollution'),
    path('report-sighting/', views.CoralSightingCreateView.as_view(), name='report_sighting'),
    path('contact/', views.ContactView.as_view(), name='contact'),

    # Gallery
    path('gallery/', views.GalleryView.as_view(), name='gallery'),
    path('upload/', views.ImageUploadView.as_view(), name='upload_media'),

    # User Profile
    path('profile/', views.UserProfileView.as_view(), name='profile'),
    path('profile/<int:pk>/', views.UserProfileView.as_view(), name='user_profile'),
    path('profile/edit/', views.UserProfileEditView.as_view(), name='profile_edit'),

    # Dashboard (Researchers/Admins only)
    path('dashboard/', views.DashboardView.as_view(), name='dashboard'),

    # Data Export (Researchers/Admins only)
    path('export/reefs/', views.ExportReefsView.as_view(), name='export_reefs'),
    path('export/events/', views.ExportEventsView.as_view(), name='export_events'),

    # Bookmarks
    path('bookmarks/', views.BookmarkListView.as_view(), name='bookmarks'),
    path('bookmark/<int:reef_id>/toggle/', views.bookmark_toggle, name='bookmark_toggle'),

    # Authentication
    path('register/', views.UserRegistrationView.as_view(), name='register'),
    path('login/', views.CustomLoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),

    # Password reset
    path('password-reset/', views.CustomPasswordResetView.as_view(), name='password_reset'),
    path('password-reset/done/', PasswordResetDoneView.as_view(
        template_name='core/password_reset_done.html'
    ), name='password_reset_done'),
    path('password-reset-confirm/<uidb64>/<token>/', PasswordResetConfirmView.as_view(
        template_name='core/password_reset_confirm.html'
    ), name='password_reset_confirm'),
    path('password-reset-complete/', PasswordResetCompleteView.as_view(
        template_name='core/password_reset_complete.html'
    ), name='password_reset_complete'),
]
