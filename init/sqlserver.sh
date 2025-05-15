#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright 2025 U Servers Comunicaciones, S.C.
# SPDX-License-Identifier: Apache-2.0

# This is an initialization script to initialize a MySQL server. It will 
# partition and format a drive, mount it on /var/lib/mysql and install the
# mysql community server.

if [ ! -b /dev/sdb1 ]; then
 parted /dev/sdb mklabel gpt
 parted -a opt /dev/sdb mkpart primary ext4 0% 100%
 mkfs.ext4 -L data /dev/sdb1
 mkdir -p /var/lib/mysql
fi

grep /dev/sdb1 /etc/fstab  ||  echo "/dev/sdb1 /var/lib/mysql          ext4    defaults        1 2" >> /etc/fstab

df | grep /dev/sdb1 || mount /dev/sdb1 

yum install -y https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm

if df | grep /dev/sdb1; then
    yum install -y mysql-server
    grep mysql_native_password /etc/my.cnf || echo 'mysql_native_password=ON' >> /etc/my.cnf
    systemctl enable mysqld
    systemctl start mysqld

fi

yum install -y epel-release
yum install -y phpmyadmin joe

sed -i 's|Alias /phpMyAdmin|#Alias /phpMyAdmin|' /etc/httpd/conf.d/phpMyAdmin.conf 
sed -i 's|Alias /phpmyadmin|Alias /__phpmyadmin|' /etc/httpd/conf.d/phpMyAdmin.conf 

systemctl enable httpd
systemctl start httpd
