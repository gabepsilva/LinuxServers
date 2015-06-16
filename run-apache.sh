#!/bin/bash


currentDir=$(dirname ${BASH_SOURCE[0]})

# Load variables, functions and properties
. ${currentDir}/linuxServers.properties
. ${currentDir}/varsAndFuncs.sh

#Update system > (in varsAndFuncs.sh)
systemUpdate

printLog "Packages Install"
apt-get install -y ${installPackagesApache2}

printLog "Create Certificates"
echo ${certString} 
openssl req \
    -new \
    -newkey rsa:${rsaLevel} \
    -days ${certLength} \
    -nodes \
    -x509 \
    -subj "${certString}" \
    -keyout ${keyFilename} \
    -out ${certFilename}
	
echo ${keyFilename}
echo ${certFilename}	
#move certificates to final destiny
mkdir -p ${certInstallPath}
mv ${keyFilename} ${certInstallPath}
mv ${certFilename} ${certInstallPath}


printLog "PHP5 configuration"

cp /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.orig
sed -e "s/max_execution_time = .*/max_execution_time = ${max_execution_time}/" \
-e "s/max_input_time = .*/max_input_time = ${max_input_time}/" \
-e "s/memory_limit = .*/memory_limit = ${memory_limit}/" \
-e "s/post_max_size = .*/post_max_size = ${post_max_size}/" \
-e "s/upload_max_filesize = .*/upload_max_filesize = ${upload_max_filesize}/" /etc/php5/apache2/php.ini.orig > /etc/php5/apache2/php.ini

cp /etc/php5/cli/php.ini /etc/php5/cli/php.ini.orig
sed -e "s/max_execution_time = .*/max_execution_time = ${max_execution_time}/" \
-e "s/max_input_time = .*/max_input_time = ${max_input_time}/" \
-e "s/memory_limit = .*/memory_limit = ${memory_limit}/" \
-e "s/post_max_size = .*/post_max_size = ${post_max_size}/" \
-e "s/upload_max_filesize = .*/upload_max_filesize = ${upload_max_filesize}/" /etc/php5/cli/php.ini.orig > /etc/php5/cli/php.ini
#create php config check file
mkdir -p ${ApacheDocumentRoot}
echo "<?php phpinfo( ); ?>" > ${ApacheDocumentRoot}/index.php 


printLog "Apache2 configuration"

cp /etc/apache2/ports.conf /etc/apache2/ports.orig 
sed -e "s/<ApachePort>/${ApachePort}/" \
-e "s/<ApacheHTTPSport>/${ApacheHTTPSport}/" ${currentDir}/apache2/apache2-ports.conf.template  > /etc/apache2/ports.conf

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.orig
sed -e "s/<ApachePort>/${ApachePort}/" \
-e "s@<ApacheHTTPSport>@${ApacheHTTPSport}@" \
-e "s@<ApacheDocumentRoot>@${ApacheDocumentRoot}@" \
-e "s@<ApacheServerAlias>@${ApacheServerAlias}@" \
-e "s/<ApacheServerAdmin>/${ApacheServerAdmin}/" \
-e "s@<certInstallPath>@${certInstallPath}@" \
-e "s@<keyFilename>@${keyFilename}@" \
-e "s@<certFilename>@${certFilename}@" \
-e "s@<ApacheServerName>@${ApacheServerName}@" ${currentDir}/apache2/apache2-default.conf.template > /etc/apache2/sites-available/000-default.conf

fixPermissions

a2enmod rewrite
a2enmod ssl
a2ensite default-ssl
php5enmod mcrypt 
service apache2 restart

