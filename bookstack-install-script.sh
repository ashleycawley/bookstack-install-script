#!/bin/bash

# Notes:

# Exit Codes:
# 0 - OK

# Variables
WEB_ROOT="/home/user/site/public_html" # Full Path. ie. /home/user/public_html
SITE_URL="https://notes.com" # No trailing slash
DB_NAME="oq9J3dbVExcL"
DB_USER="oq9J3dbVExcL"
DB_PASS='r&R%.>2^)TVx'

# Sanitising user supplied variables to work nicely with sed later on
DB_PASS_SANITISED=$(echo $DB_PASS | sed 's#\([]\#\%\@\*\$\/&[]\)#\\\1#g')
SITE_URL_SANITISED=$(echo $SITE_URL | sed 's#\([]\#\%\@\*\$\/&[]\)#\\\1#g')

# Main Script
cd "$WEB_ROOT"

# Pulls down BookStack from Repository
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch

cd ./BookStack/

# Install using Composer
composer install --no-dev

# Setup configuration file
cp .env.example .env

# Updates configuration file with our database details
sed -i "s/database_database/$DB_NAME/g" .env
sed -i "s/database_username/$DB_USER/g" .env
sed -i "s/database_user_password/$DB_PASS_SANITISED/g" .env

# Replaces example site URL with users real one
sed -i "s/https:\/\/example.com/$SITE_URL_SANITISED/g" .env

# Generates Unique Application Key
php artisan key:generate --force

# Populates database with data structure
php artisan migrate --force