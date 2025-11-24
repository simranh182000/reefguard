"""
ASGI config for ReefGuard project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ReefGuard.settings')

application = get_asgi_application()
