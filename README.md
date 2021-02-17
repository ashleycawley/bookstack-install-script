# bookstack-install-script
A **unofficial** automatic installation script for [BookStack](https://www.bookstackapp.com/) designed for CentOS / RedHat systems.

The script does not handle the configuration of your Web Server, Dcoument Root or create MySQL databases. It works in conjunction with other systems I use elsewhere however I thought I would share it in case of any of the code is useful to anyone else. 

**Prerequisites**
This script assumes that you have the following already installed:
* git
* composer
* NGINX
* MySQL 5.7.33 or newer
* PHP 7.2 or PHP 7.3
(php72u php72u-cli php72u-fpm php72u-gd php72u-json php72u-mbstring php72u-mysqlnd php72u-openssl php72u-tidy php72u-tokenizer php72u-xml)
