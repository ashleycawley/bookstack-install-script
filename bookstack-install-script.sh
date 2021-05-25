#!/bin/bash

# Notes: Please check prerequisites and documentation in README.md or at:
#        https://github.com/ashleycawley/bookstack-install-script
#
# Elements to gather from the user:
# - Database Username
# - Database Password
# - 
# - 
#

# Exit Codes:
# 0 - OK

# Whiptail GUI Menu gathering settings from the sysadmin

DB_URL$(whiptail --inputbox "Ener in the Site URL (with NO trailing slash):" 8 39 https:// --title "Site URL" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo "Cancelled."
fi

DB_NAME=$(whiptail --inputbox "Enter in the Database Name that Scout provided to you:" 8 39 --title "Database Name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo "Cancelled."
fi

DB_USER=$(echo $DB_NAME) # In Scout the Database Name and Username are the same, so we are deriving the database username automagically.

DB_PASS=$(whiptail --inputbox "Enter in the Database Password that Scout provided to you:" 8 39 --title "Database Password" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo "Cancelled."
fi



# Variables
WEB_ROOT="/home/user/site/public_html" # Full Path. ie. /home/user/public_html
DB_NAME="oq9J3dbVExcL"

# $(echo "$(hostname)$(hostname -I)$(date +%s)$(echo $RANDOM)" | sha1sum | cut -c1-12) # Randomly generated database password

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

# Replaces SMTP Email method for PHP sendmail
sed -i "s/MAIL_DRIVER=smtp/MAIL_DRIVER=sendmail/g" .env

# Generates Unique Application Key
php artisan key:generate --force

# Populates database with data structure
php artisan migrate --force