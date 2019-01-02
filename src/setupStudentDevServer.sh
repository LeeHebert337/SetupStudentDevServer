#!/bin/bash
#
# Script to build a student dev server on Ubuntu running under Oracle Virtual Box
# Oracle Virtual Box must be setup on a Windows 10 machine and Ubuntu must also be setup.
# Run this script after Ubuntu is setup
# Must be ran with sudo
# Installs the following
#    - Apache2
#    - mariadb
#    - PHP
#    - Oracle Java
#    - Tomcat
#
#
# Caution:   This setup should not be used for a production or external facing server.   
# The setup from this script is not specificaly secure and meant to make it eaiser on Students
#
PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}
getAccountInfo()
{
read -p 'Username setup during Ubuntu Install: ' uservar
read -p 'Password: ' passvar
echo 
}
clear
getAccountInfo
echo User Account being used is $uservar
echo  -------------Updating Linux------------- 
#apt update
apt --yes --force-yes -q  update || error_exit "Aborting - Cannot execute apt update!"
apt --yes --force-yes -q --show-progress  full-upgrade || error_exit "Aborting - Cannot execute apt upgrade!"
apt --yes --force-yes -q --show-progress  install software-properties-common || error_exit "Aborting - Cannot install software-properties-common!"
echo   -------------Installing Apache Web Server-------------  
add-apt-repository --yes  ppa:ondrej/apache2 || error_exit "Aborting - Cannot add apache repository!"
apt --yes --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding apache repository!"
apt --yes --force-yes -q install apache2 || error_exit "Aborting - Cannot install apache!"
cd /var/www || error_exit "Aborting - Cannot located apache /var/www!"
chmod 777 * || error_exit "Aborting - Cannot perform chmod on /var/www!"
echo -------------Setup CGI on Apache under /www/var/cgi-------------
mkdir cgi
chmod 777 cgi  || error_exit "Aborting - Cannot perform chmod on /var/www/cgi!"
cp /etc/apache2/mods-available/cg* /etc/apache2/mods-enabled || error_exit "Aborting - Cannot perform copy on Apache CGI modules"
cat  <<EOT > /etc/apache2/conf-enabled/cgi.conf
Alias /cgi/ "/var/www/cgi/"
<Directory /var/www/cgi/>
Options Indexes FollowSymLinks Includes ExecCGI
</Directory>
AddHandler cgi-script .cgi .pl .py .sh
EOT
/etc/init.d/apache2 restart  || error_exit "Aborting - Cannot restart Apache!"
echo -------------Install MariaDB SQL Database Server-------------
apt-get --yes --force-yes -q remove mariadb-server
apt-key adv --yes -q --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 || error_exit "Aborting - Cannot add Key!"
add-apt-repository --yes 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/10.3/ubuntu bionic main' || error_exit "Aborting - Cannot add mariadb repository!"
apt --yes  --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding mariadb repository!"
apt --yes --force-yes -q install mariadb-server mariadb-client || error_exit "Aborting - Cannot install mariadb!"
mysql -V || error_exit "Aborting - MariaDB did not seem to install!"
#mysql --user=root --password -s 
cat /etc/mysql/mariadb.conf.d/50-server.cnf | sed -e 's/\[mysqld\]/\[mysqld\]\nplugin-load-add = auth_socket.so/' > /tmp/50-server.cnf
mv  -f /tmp/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf || error_exit "Aborting - Cannot move 50-server.cnf file!"
systemctl restart mariadb.service || error_exit "Aborting - Cannot restart mariadb!"
cat  <<EOT > /tmp/sql.txt
create user '$uservar'@localhost identified by '$passvar';
grant all privileges on *.* to '$uservar'@localhost with grant option;
Flush privileges;
create database devdb default character set utf8 collate utf8_bin;
quit
EOT
mysql < /tmp/sql.txt
rm /tmp/sql.txt

echo -------------Install Oracle Java-------------
add-apt-repository --yes ppa:linuxuprising/java || error_exit "Aborting - Cannot add Oracle Java repository!"
apt --yes --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding java repository!"
echo oracle-java11-installer shared/accepted-oracle-license-v1-2 select true | sudo /usr/bin/debconf-set-selections
echo oracle-java11-installer shared/accepted-oracle-licence-v1-2 boolean true | sudo /usr/bin/debconf-set-selections
apt --yes  --force-yes -q  install oracle-java11-installer || error_exit "Aborting - Cannot install Oracle Java!"
apt install oracle-java11-set-default
echo -------------Install PHP - Web Dev Language-------------
apt --yes  --force-yes -q install php libapache2-mod-php php-mysql php-gd || error_exit "Aborting - Cannot install PHP!"
systemctl restart apache2
echo -------------Create PHP Information Page - http://localhost/phpinfo.php-------------
cat  <<EOT > /var/www/html/phpinfo.php
<?php
phpinfo();
>?
EOT
echo -------------Install phpMyAdmin Database Tool-------------
apt  --yes  --force-yes -q  install -y phpmyadmin || error_exit "Aborting - Cannot install phpMyAdmin!"
systemctl restart apache2
echo -------------Install Tomcat Java Server-------------
rm -rf /tmp/*tomcat* 
rm -rf /opt/tomcat
mkdir /opt/tomcat
wget http://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz -P /tmp || error_exit "Aborting - Cannot retrieve Tomcat!"
tar xf /tmp/apache-tomcat-9.0.14.tar.gz -C /opt/tomcat || error_exit "Aborting - Cannot extract Tomcat download file!"
ln -s /opt/tomcat/apache-tomcat-9.0.14 /opt/tomcat/latest  || error_exit "Aborting - Cannot create Tomcat link!"
cd /opt/tomcat/latest
chown -RH $uservar /opt/tomcat/latest
chmod o+x /opt/tomcat/latest/bin/
cat  <<EOT > /opt/tomcat/latest/conf/tomcat-users.xml 
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="admin-gui"/>
  <role rolename="manager-gui"/>
  <user username="$uservar" password="$passvar" roles="manager-gui,admin-gui"/>
</tomcat-users>			  
EOT
echo -------------Install LISP Language-------------
apt --yes --force-yes -q install sbcl || error_exit "Aborting - Cannot install LISP!"
#echo -------------Install Prolog Language -------------
#add-apt-repository --yes ppa:swi-prolog/stable || error_exit "Aborting - Cannot add Prolog repository!"
#apt --yes --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding Prolog repository!"
#apt  --yes --force-yes -q  install swi-prolog || error_exit "Aborting - Cannot install Prolog!"
echo -------------Install R Language-------------
apt --yes --force-yes -q install r-base || error_exit "Aborting - Cannot install R!"
echo -------------Install Scala Language-------------
apt --yes --force-yes -q install scala || error_exit "Aborting - Cannot install Scala!"
echo -------------Install GIT Tool-------------
apt --yes --force-yes -q install git || error_exit "Aborting - Cannot install GIT!"
echo -------------Install Python PIP Tool-------------
apt --yes --force-yes -q install python-pip || error_exit "Aborting - Cannot install Python PIP!"
#echo -------------Install Spark Language-------------
#mkdir /opt/spark
#wget https://www.apache.org/dyn/closer.lua/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz -P /tmp || error_exit "Aborting - Cannot retrieve Spark!"
#tar xf /tmp/spark-2.4.0-bin-hadoop2.7.tgz -C /opt/spark || error_exit "Aborting - Cannot extract Spark download file!"
#pip install pyspark
echo -------------Install C# Language - Mono-------------
#apt-add-repository  --yes ppa:directhex/ppa || error_exit "Aborting - Cannot add Mono repository!"
#apt --yes --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding Mono repository!"
#apt  --yes --force-yes -q  install monodevelop || error_exit "Aborting - Cannot install Mono!"
#apt  --yes --force-yes -q  install mcs || error_exit "Aborting - Cannot install MCS Tool!"
apt --yes --force-yes -q install mono-complete || error_exit "Aborting - Cannot install Mono complete!"
apt --yes --force-yes -q install libapache2-mod-mono mono-apache-server4 || error_exit "Aborting - Cannot install Mono for Apache!"

echo -------------Install Bluefish Editor-------------
apt-add-repository  --yes ppa:klaus-vormweg/bluefish || error_exit "Aborting - Cannot add bluefish repository!"
apt --yes --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding bluefish repository!"
apt  --yes --force-yes -q  install bluefish || error_exit "Aborting - Cannot install bluefish Tool!"


echo ----------------- Development Languages and Tools Available -----------------
echo - Apache2 Web Server
echo - MariaDB Database Server
echo - phpMyAdmin \(Database Tool http://localhost/phpmyadmin\)
echo - Tomcat Java Application Server
echo - GIT Tools
echo - PHP Information Page  \(http://localhost/phpinfo.php\)
echo - Bluefish Editor
echo
echo - C \(gcc\)
echo - C++ \(g++\)
echo - Perl
echo - Python3
echo - Java
echo - PHP
echo - C# \(Mono\)
echo - LISP \(Mono\)
echo - Unix Shell Scripting
echo - Google Go
echo - R
echo ---- Script Complete ----

