#!/bin/bash

export DEBIAN_FRONTEND=noninteractive



#simple function to send build log
printLog()
{

	#echo "================================="
	echo ""
	echo -e "\e[92m$1\e[0m"
	echo ""
	#echo "================================="

}

#update package list
systemUpdate()
{

printLog "Package List Update"
apt-get update

printLog "Package Removes"
apt-get -y purge ${purgeList}

printLog "System Upgrade"
apt-get -y upgrade

printLog "Packages Auto-Remove"
apt-get -y autoremove

}


fixPermissions()
{

printLog "Setting Permissions"

chown -R www-data:root ${ApacheDocumentRoot}
find ${ApacheDocumentRoot} -type d -exec chmod u=rwx,g=rx,o= '{}' \;
find ${ApacheDocumentRoot} -type f -exec chmod u=rw,g=r,o= '{}' \;

}