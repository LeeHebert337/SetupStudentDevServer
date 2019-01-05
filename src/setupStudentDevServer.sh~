#!/bin/bash
# version 1.2
# Script to build a student dev server on Ubuntu running under Oracle Virtual Box
# Oracle Virtual Box must be setup on a Windows 10 machine and Ubuntu must also be setup.
# Run this script after Ubuntu is setup
# Must be ran with sudo  example   sudo .\setupStudentServer.sh
# 
# Caution:   This setup should not be used for a production or external facing server.   
# The setup from this script is not specificaly secure and meant to make it eaiser on Students learning software development
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
killall VBoxClient
VBoxClient-all
echo  -------------Updating Linux------------- 
apt --yes --force-yes -q  update || error_exit "Aborting - Cannot execute apt update!"
apt --yes --force-yes -q --show-progress  full-upgrade || error_exit "Aborting - Cannot execute apt upgrade!"
apt --yes --force-yes -q --show-progress  install gucharmap clang libicu-dev rlwrap apt-transport-https curl libssl-dev ant libcanberra-gtk-module libcanberra-gtk3-module software-properties-common gnome-tweak-tool flex bison gtk-doc-tools gobject-introspection || error_exit "Aborting - Cannot install linux tool!"





mkdir /mnt/share
chmod 777 /mnt/share
cd
cat  <<EOT > mountVboxShare
sudo mount -t vboxsf -o uid=1000,gid=1000 LinuxShare /mnt/share
EOT
chmod 777 mountVboxShare

echo   -------------Installing Google Chrome Browser------------- 
apt --yes --force-yes -q --show-progress  install  gdebi-core || error_exit "Aborting - Cannot install gdebi!" 
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp || error_exit "Aborting - Cannot retrieve Google Chrome!"
dpkg -i /tmp/google-chrome-stable_current_amd64.deb || error_exit "Aborting - Cannot install Google Chrome!"

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
wget https://www.prodefence.org/wp-content/uploads/2017/06/apache-web-server.png -P /usr/share/apache2/icons
mv /usr/share/apache2/icons/apache-web-server.png /usr/share/apache2/icons/apacheleft.png
wget https://endertech.com/wp-content/uploads/2017/09/apache-logo.png -P /usr/share/apache2/icons
mv /usr/share/apache2/icons/apache-logo.png /usr/share/apache2/icons/apacheup.png
wget https://d3eaqdewfg2crq.cloudfront.net/wp-content/uploads/2012/10/apache-http-server-insignia.png -P /usr/share/apache2/icons
mv /usr/share/apache2/icons/apache-http-server-insignia.png /usr/share/apache2/icons/pacheright.png
cat  <<EOT > /usr/share/applications/apache-start.desktop 
[Desktop Entry]
Name=Apache Start Service
Exec=systemctl start apache2.service	
Terminal=true
Type=Application
Icon=/usr/share/apache2/icons/apacheup.png
NoDisplay=false
EOT
cat  <<EOT > /usr/share/applications/apache-restart.desktop 
[Desktop Entry]
Name=Apache Restart Service
Exec=systemctl restart apache2.service	
Terminal=true
Type=Application
Icon=/usr/share/apache2/icons/apacheright.png
NoDisplay=false
EOT
cat  <<EOT > /usr/share/applications/apache-stop.desktop 
[Desktop Entry]
Name=Apache Stop Service
Exec=systemctl stop apache2.service	
Terminal=true
Type=Application
Icon=/usr/share/apache2/icons/apacheleft.png
NoDisplay=false
EOT
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
?>
EOT
wget  https://pngimg.com/uploads/php/php_PNG48.png -P /usr/share/php
cat  <<EOT > /usr/share/applications/phpinfo.desktop 
[Desktop Entry]
Name=PHP Info
Comment=General Information about PHP
Exec=sensible-browser http://localhost/phpinfo.php/
Terminal=false
Type=Application
Icon=/usr/share/php/php_PNG48.png
Categories=Development;php;
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

cat  <<EOT > /usr/share/applications/tomcat.desktop 
[Desktop Entry]
Name=Tomcat Server Page
Comment=Tomcat Server Page
Exec=sensible-browser http://localhost:8080
Terminal=false
Type=Application
Icon=/tomcat/latest/webapps/root/tomcat.png
Categories=Development;java;tomcat
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
snap install --classic hub

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

#echo -------------Install Bluefish Editor-------------
#apt-add-repository  --yes ppa:klaus-vormweg/bluefish || error_exit "Aborting - Cannot add bluefish repository!"
#apt --yes --force-yes -q update || error_exit "Aborting - Cannot execute apt update after adding bluefish repository!"
apt  --yes --force-yes -q  install bluefish || error_exit "Aborting - Cannot install bluefish Tool!"

echo -------------Install Netbeans IDE-------------
rm -f /tmp/*netbeans*
wget http://mirrors.ibiblio.org/apache/incubator/netbeans/incubating-netbeans/incubating-10.0/incubating-netbeans-10.0-bin.zip -P /tmp || error_exit "Aborting - Cannot retrieve Netbeans10!"
rm -rf /opt/netbeans
unzip /tmp/incubating-netbeans-10.0-bin.zip -d /opt
cat  <<EOT > /usr/share/applications/netbeans.desktop 
[Desktop Entry]
Version=1.0
Name=Netbeans IDE
Comment=Web Development Editor
Keywords=programming;code;web;editor;development;html;php;python,java;
Exec=/opt/netbeans/bin/netbeans
Icon=/opt/netbeans/nb/netbeans.png
Terminal=false
Type=Application
StartupNotify=true
Categories=GTK;GNOME;Development;WebDevelopment;
MimeType=text/html;text/css;text/x-javascript;text/x-python;text/x-perl;application/x-php;text/x-java;text/javascript;text/x-php;application/x-cgi;application/x-javascript;application/x-perl;application/x-python;application/xhtml+xml;text/mathml;text/x-csrc;text/x-chdr;text/x-dtd;text/x-sql;text/xml		  
EOT


echo -------------GODOT Game Engine-------------
rm -f /tmp/*godot*
wget https://downloads.tuxfamily.org/godotengine/3.0.6/Godot_v3.0.6-stable_x11.64.zip -P /tmp || error_exit "Aborting - Cannot retrieve godot!"
rm -rf /opt/godot
mkdir /opt/godot
mkdir /opt/godot/bin
unzip /tmp/Godot_v3.0.6-stable_x11.64.zip  -d /opt/godot/bin
mv /opt/godot/bin/Godot_v3.0.6-stable_x11.64 /opt/godot/bin/godot
wget https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg -P /opt/godot
cat  <<EOT > /usr/share/applications/godot.desktop 
[Desktop Entry]
Version=1.0
Name=GODOT Game Engine
Comment=Game Development IDE
Keywords=programming;code;IDE;development;python,game
Exec=/opt/godot/bin/godot
Icon=/opt/godot/Godot_icon.svg
Terminal=false
Type=Application
StartupNotify=true
Categories=GTK;GNOME;Development;GameDevelopment;python, game
EOT

echo -------------Install Anjuta IDE-------------
apt --yes --force-yes -q --show-progress  install anjuta || error_exit "Aborting - Cannot install Anjuta IDE!"

echo -------------Install Geany Editor-------------
apt --yes --force-yes -q --show-progress  install geany || error_exit "Aborting - Cannot install Geany Editor!"

echo -------------Install Meld File Compare Tool-------------
apt --yes --force-yes -q --show-progress  install meld || error_exit "Aborting - Cannot install Meld!"

echo -------------Install Ruby Language-------------
snap install --classic ruby

echo -------------Install Eclipse IDE-------------
sudo snap install eclipse --candidate --classic

echo -------------Install Microsoft Powershell-------------
sudo snap install powershell --classic

echo -------------Install Microsoft Visual Studio Code IDE-------------
sudo snap install vscode --classic

echo -------------Install PyCharm Python IDE-------------
sudo snap install pycharm-community --classic


echo -------------Install IntelliJ  IDE-------------
snap install intellij-idea-community --classic

echo -------------Install Node.js-------------
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
apt --yes --force-yes -qinstall -y nodejs

echo -------------Install CoffeeScript-------------
npm install -g coffeescript

echo -------------Install Dart-------------
sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
apt --yes --force-yes -q  update || error_exit "Aborting - Cannot execute apt update after Dart Repository!"
apt --yes --force-yes -q --show-progress  install dart || error_exit "Aborting - Cannot install dart!"

echo -------------Install Clojure-------------
cd /tmp
curl -O https://download.clojure.org/install/linux-install-1.10.0.408.sh
chmod +x linux-install-1.10.0.408.sh
sudo ./linux-install-1.10.0.408.sh

echo -------------Install Swift-------------
cd /tmp
wget https://swift.org/builds/swift-4.2.1-release/ubuntu1804/swift-4.2.1-RELEASE/swift-4.2.1-RELEASE-ubuntu18.04.tar.gz
tar xzf swift-4.2.1-RELEASE-ubuntu18.04.tar.gz
mv swift-4.2.1-RELEASE-ubuntu18.04 /opt/swift

echo ----------------- Development Tools Available -----------------
echo - Apache2 Web Server
echo - MariaDB Database Server with initial devdb database
echo - phpMyAdmin \(Database Tool http://localhost/phpmyadmin\)
echo - Tomcat Java Application Server \( http://localhost:8080\)
echo - Node.js
echo - GIT Tools
echo - PHP Information Page  \(http://localhost/phpinfo.php\)
echo - Google Chrome
echo - Bluefish Editor
echo - Geany Editor
echo - Netbeans10 IDE
echo - Anjuta IDE
echo - Eclipse IDE
echo - IntelliJ IDE
echo - PyCharm Python IDE
echo - Microsoft Visual Studio Code IDE
echo - Meld \(visual Difference and Merge Tool\)
echo ----------------- Development Languages -----------------
echo - C \(gcc\)
echo - C++ \(g++\)
echo - Perl
echo - Python3
echo - Java
echo - PHP
echo - C# \(Mono\)
echo - LISP
echo - Unix Shell Scripting
echo - Google Go
echo - R
echo - Scala
echo - Ruby
echo - Microsoft Powershell
echo - CoffeeScript
echo - Dart
echo - Clojure
echo - Swift
echo - GODOT Game Engine
echo ---- Script Complete ----

