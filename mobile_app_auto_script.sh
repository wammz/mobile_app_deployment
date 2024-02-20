#!/bin/bash
#
# script to automate deployment of mobile app suite for EHR
#
#first copy the mobile app tarball to server's /home/administrator dir
# ensure that this script is in /home/administrator
# untar tarball
tarball=mobile_app_backup.tar.xz
source_dir=/home/administrator/mobile_app_backup
dest_dir=/var/lib/mrs/
mobile_home_dir=/var/lib/mrs/mobile_app_backup
# change this before running
site_code=ZW006654
echo -e "***************************************\n 
This ensure you have changed the site code to match this facility\n*********************"
tar -xfv $tarball
rm -f $tarball
# move these resources into /home/administrator
mv $source_dir/backup-infrastructure.tar ../
mv $source_dir/mobile-client.tar ../
#
# move whole mobile dir
mv $source_dir /var/lib/mrs/
# docker load
docker load -i $source_dir/mobile-client-v1.0.tar
docker load -i $source_dir/backup-infrastructure.tar
# cd into /var/lib/mrs
cd $dest_dir
#bring down EHR services
echo "Bringing EHR down....\n"
docker-compose down
echo "EHR down...Please check your compose file and change accordingly \n"
# bring docker up
docker-compose up -d
# cd into mobile app dir
cd $mobile_home_dir
echo -e "Please edit env file....\nchange site_id under mobile client to match this site \n"
echo -e "change credentials for the mobile app user\n"
# bring up docker
docker-compose up -d
#
# cd into connectors dir
cd $mobile_home_dir/connectors/
# edit site id in the activate_debezium_mysql_connector.sh
# modify site_id accordingly
echo -e "Please ensure site code in this file (activate_debezium_mysql_connector) matches the facility site code\n"
#edit activate_http_sink_connector.sh
#edit site_id accordingly
echo -e "Assuming site code in this file (activate_http_sink_connector is fine\n"
# get into mysql
# edit this to create a db in mysql
# create mysql script with table creation
docker exec -it $site_code-mysql mysql 
create database mobile;
# create table and exit
#
exit;
# run activate deb
sh activate_debezium_mysql_connector.sh
#
# change dir to mobile app home
cd $mobile_home_dir







