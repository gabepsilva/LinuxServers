#!/bin/bash

currentDir=$(dirname ${BASH_SOURCE[0]})

# Load variables, functions and properties
. ${currentDir}/linuxServers.properties
. ${currentDir}/varsAndFuncs.sh


printLog "Installing Dokuwiki"
cd ${ApacheDocumentRoot}

wget ${dokuwiliLink} -O "dokuwiki.tgz"

tar -xf dokuwiki.tgz
rm dokuwiki.tgz
mv dokuwiki* ${dokuIntallDir}


printLog "Apache Configuration"

cd -
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.orig
sed -e "s/<ApachePort>/${ApachePort}/" \
-e "s@<ApacheHTTPSport>@${ApacheHTTPSport}@" \
-e "s@<ApacheDocumentRoot>@${ApacheDocumentRoot}/${dokuIntallDir}@" \
-e "s@<ApacheServerAlias>@${ApacheServerAlias}@" \
-e "s/<ApacheServerAdmin>/${ApacheServerAdmin}/" \
-e "s@<certInstallPath>@${certInstallPath}@" \
-e "s@<keyFilename>@${keyFilename}@" \
-e "s@<certFilename>@${certFilename}@" \
-e "s@<ApacheServerName>@${ApacheServerName}@" ${currentDir}/apache2/apache2-default.conf.template > /etc/apache2/sites-available/000-default.conf

cd ${ApacheDocumentRoot}	

#------------------------------------------------------------
#Install plugins
#------------------------------------------------------------
printLog "Installing DokuwikiPlugins"

#Cryptor Plugin 
if [ "${PluginCryptorInstall}" == "yes" ]
then
	
	wget -O dokuwiki-plugin-cryptor.zip http://github.com/geofreak/dokuwiki-plugin-cryptor/archive/master.zip
	pwd
	unzip dokuwiki-plugin-cryptor.zip
	rm dokuwiki-plugin-cryptor.zip
	
	mv dokuwiki-plugin-cryptor-master ${ApacheDocumentRoot}/${dokuIntallDir}/lib/plugins/cryptor
	

fi


fixPermissions

printLog "REStart Servers"
service apache2 restart