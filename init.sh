#!/bin/sh

if [ -f /config/laravel.env ] && [ -f /config/.env ]; then
  echo "Already initialized. Skipping initialization."
  exit 0
fi

check_required_vars() {
    local missing=0

    for var in \
        APP_DOMAIN \
        APP_URL \
        APP_NAME \
        POSTGRES_HOST \
        POSTGRES_DATABASE \
        POSTGRES_USER \
        POSTGRES_PASSWORD \
        ADMIN_NAME \
        ADMIN_EMAIL \
        ADMIN_INIT_PASSWORD
    do
        if [ -z "$(eval echo "\${$var}")" ]; then
            echo "ERROR: Required environment variable '$var' is not set."
            missing=1
        fi
    done

    if [ "${missing:-0}" -eq 1 ]; then
        exit 1
    fi
}

check_optional_vars() {
    for var in \
        SMTP_HOST \
        SMTP_PORT \
        SMTP_FROM_ADDRESS \
        SMTP_FROM_NAME \
        SMTP_USERNAME \
        SMTP_PASSWORD
    do
        if [ -z "$(eval echo "\${$var}")" ]; then
            echo "WARNING: Optional environment variable '$var' is not set."
        fi
    done
}

generate_laravel_env_file() {
    cat > /config/laravel.env <<EOF
APP_NAME="${APP_NAME}"
VITE_APP_NAME="${APP_NAME}"
APP_ENV="production"
APP_DEBUG="true"
APP_URL="${APP_URL}"
APP_FORCE_HTTPS="false"
TRUSTED_PROXIES="0.0.0.0/0,2000:0:0:0:0:0:0:0/3"

# Logging
LOG_CHANNEL="stderr_daily"
LOG_LEVEL="debug"

# Database
DB_CONNECTION="pgsql"
DB_HOST="${POSTGRES_HOST}"
DB_PORT="5432"
DB_SSLMODE="require"
DB_DATABASE="${POSTGRES_DATABASE}"
DB_USERNAME="${POSTGRES_USER}"
DB_PASSWORD="${POSTGRES_PASSWORD}"

# Mail
MAIL_MAILER="smtp"
MAIL_HOST="${SMTP_HOST}"
MAIL_PORT="${SMTP_PORT}"
MAIL_ENCRYPTION="tls"
MAIL_FROM_ADDRESS="${SMTP_FROM_ADDRESS}"
MAIL_FROM_NAME="${SMTP_FROM_NAME}"
MAIL_USERNAME="${SMTP_USERNAME}"
MAIL_PASSWORD="${SMTP_PASSWORD}"

# Queue
QUEUE_CONNECTION="database"

# File storage
FILESYSTEM_DISK="local"
PUBLIC_FILESYSTEM_DISK="public"

# Services
GOTENBERG_URL="http://solidtime-gotenberg:3000"

# Authentication
EOF

    php artisan self-host:generate-keys >> /config/laravel.env

    cp /config/laravel.env /var/www/html/.env

    php artisan migrate --force

    printf '%s\n' "${ADMIN_INIT_PASSWORD}" | php artisan admin:user:create "${ADMIN_NAME}" "${ADMIN_EMAIL}" --verify-email --ask-for-password

    echo "SUPER_ADMINS=${ADMIN_EMAIL}" >> /config/laravel.env
}

generate_env_file() {
    cat > /config/.env <<EOF
APP_DOMAIN="${APP_DOMAIN}"
DB_DATABASE="${POSTGRES_DATABASE}"
DB_USERNAME="${POSTGRES_USER}"
FORWARD_APP_PORT=8000
FORWARD_DB_PORT=5432
DB_PASSWORD="${POSTGRES_PASSWORD}"
EOF
}

check_required_vars
check_optional_vars
generate_env_file
generate_laravel_env_file

if [ -f /config/laravel.env ]; then
    exit 0
else
    exit 1
fi
