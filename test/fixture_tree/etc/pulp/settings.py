CONTENT_HOST = "katello.example.com"
CONTENT_ORIGIN = "https://katello.example.com"
SECRET_KEY = "verysecretkey"
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'pulpcore',
        'USER': 'pulp',
        'PASSWORD': 'verysecurepassword',
        'HOST': 'localhost',
        'PORT': '5432',
    },
}

USE_NEW_WORKER_TYPE = True

MEDIA_ROOT = "/var/lib/pulp/media"
STATIC_ROOT = "/var/lib/pulp/assets"
STATIC_URL = "/pulp/assets/"
FILE_UPLOAD_TEMP_DIR = "/var/lib/pulp/tmp"
WORKING_DIRECTORY = "/var/lib/pulp/tmp"

REMOTE_USER_ENVIRON_NAME = 'HTTP_REMOTE_USER'
AUTHENTICATION_BACKENDS = ['pulpcore.app.authentication.PulpNoCreateRemoteUserBackend']

REST_FRAMEWORK__DEFAULT_AUTHENTICATION_CLASSES = (
    'rest_framework.authentication.SessionAuthentication',
    'pulpcore.app.authentication.PulpRemoteUserAuthentication'
)

ALLOWED_IMPORT_PATHS = ["/var/lib/pulp/sync_imports", "/var/lib/pulp/imports"]
ALLOWED_EXPORT_PATHS = ["/var/lib/pulp/exports"]

# Derive HTTP/HTTPS via the X-Forwarded-Proto header set by Apache
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

CACHE_ENABLED = False

LOGGING = {
    "dynaconf_merge": True,
    "loggers": {
        '': {
            'handlers': ['console'],
            'level': 'INFO',
        }
    }
}

# container plugin settings
TOKEN_AUTH_DISABLED=True
