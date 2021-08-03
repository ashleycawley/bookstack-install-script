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
# 1 - The user ran the script as root instead of a normal user
# 2 - User exited whiptail menu whilst at data gathering stage

# Variables
WEB_ROOT="/home/$(whoami)/site/public_html" # Full Path. ie. /home/user/public_html
# $(echo "$(hostname)$(hostname -I)$(date +%s)$(echo $RANDOM)" | sha1sum | cut -c1-12) # Randomly generated database password

# Root Check
if [ `whoami` == "root" ]
then
    whiptail --title "! ~ Root User Detected ~ !" --msgbox "You ran this script as root, the police have been informed..." 8 65
    whiptail --title "! ~ Root User Detected ~ !" --msgbox "Please run this script as the standard web user, not root." 8 65
    echo "Go find the Scout Web User <3"
    exit 1
else
    USER=$(whoami)
	fi

# Whiptail GUI Menu gathering settings from the sysadmin
SITE_URL=$(whiptail --inputbox "Enter in the Site URL (with NO trailing slash):" 8 65 https:// --title "Site URL" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo "Cancelled."
    exit 2
fi

DB_NAME=$(whiptail --inputbox "Enter in the Database Name that Scout provided to you:" 8 65 --title "Database Name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo "Cancelled."
    exit 2
fi

DB_USER=$(echo $DB_NAME) # In Scout the Database Name and Username are the same, so we are deriving the database username automagically.

DB_PASS=$(whiptail --inputbox "Enter in the Database Password that Scout provided to you:" 8 65 --title "Database Password" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo "Cancelled."
    exit 2
fi

# Sanitising user supplied variables to work nicely with sed later on
DB_PASS_SANITISED=$(echo $DB_PASS | sed 's#\([]\#\%\@\*\$\/&[]\)#\\\1#g')
SITE_URL_SANITISED=$(echo $SITE_URL | sed 's#\([]\#\%\@\*\$\/&[]\)#\\\1#g')


whiptail --title "Settings Review" --msgbox "Here are your settings: \n\n  Username:   $USER \n  Web Root:   /home/$USER/site/public_html \n  Website:    $SITE_URL \n  DB Name:    $DB_NAME \n  DB Pass:    $DB_PASS_SANITISED" 14 78

cd "$WEB_ROOT" &>/dev/null
WEB_ROOT_DIR_STATUS=$(echo $?)

if [ "$WEB_ROOT_DIR_STATUS" != "0" ]
then
    whiptail --title "Web Root Problem" --msgbox "I do beg your pardon, but I thought the user was $USER and on a Scout server their web root should be at: $WEB_ROOT but I can't see that directory on disk." 10 65

    if (whiptail --title "New Directory?" --yesno "Would you like to supply a new Web Root path?" 8 65); then
    
    WEB_ROOT=$(whiptail --inputbox "Enter a new Web Root path:" 8 65 --title "New Web Root" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        cd "$WEB_ROOT" &>/dev/null
        WEB_ROOT_DIR_STATUS=$(echo $?)
        if [ "$WEB_ROOT_DIR_STATUS" != "0" ]
        then
            echo "There is still a problem with $WEB_ROOT so we're now exiting..."
            exit 2
        else
            if (whiptail --title "Web Root Check" --yesno "Are you happy for me to install BookStack to $WEB_ROOT ? \nSize of that folder currently: `du -sh $WEB_ROOT | awk '{print $1}'`" 10 65)
            then
                STATE="OK"
            else
                echo "Cancelling."
                exit 2
            fi
            echo "Great, $WEB_ROOT works for me, so lets install BookStack there then..." && sleep 5
        fi
    else
        echo "Cancelled."
        exit 2
    fi

    else
    echo "You selected No, I guess we'll try again another day?"
    exit 2
    fi

fi

# Pulls down BookStack from Repository
echo "Downloading BookStack Software from https://github.com/BookStackApp/BookStack.git" && sleep 2
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch

# # If BookStack folder does not exist then create it
# if [ ! -d "cd ~site/public_html/BookStack/" ]
# then
#     mkdir -p ~site/public_html/BookStack/
# fi

# cd ~site/public_html/BookStack/

echo "Installing using Composer"
composer install --no-dev

echo "Setting up configuration file"
cp .env.example .env

echo "Updating configuration file with our database details"
sed -i "s/database_database/$DB_NAME/g" .env
sed -i "s/database_username/$DB_USER/g" .env
sed -i "s/database_user_password/$DB_PASS_SANITISED/g" .env

echo "Replacing example site URL with users real one"
sed -i "s/https:\/\/example.com/$SITE_URL_SANITISED/g" .env

echo "Replacing SMTP Email method for PHP sendmail"
sed -i "s/MAIL_DRIVER=smtp/MAIL_DRIVER=sendmail/g" .env

echo "Generate Unique Application Key"
php artisan key:generate --force

echo "Populate database with data structure"
php artisan migrate --force