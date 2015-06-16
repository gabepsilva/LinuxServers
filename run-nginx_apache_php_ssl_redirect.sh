#!/bin/bash



currentDir=$(dirname ${BASH_SOURCE[0]})

# Load variables, functions and properties
. ${currentDir}/linuxServers.properties
. ${currentDir}/varsAndFuncs.sh

#Update system > (in varsAndFuncs.sh)
systemUpdate

printLog "Packages Install"
apt-get install -y ${installPackagesNginx}


printLog "Nginx Configuration"

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.orig
sed -e "s@<NginxPort>@${NginxPort}@" \
-e "s@<NginxHTTPSport>@${NginxHTTPSport}@" \
-e "s@<NginxDocumentRoot>@${NginxDocumentRoot}@" \
-e "s@<certFilename>@${certFilename}@" \
-e "s@<keyFilename>@${keyFilename}@" \
-e "s@<certInstallPath>@${certInstallPath}@" \
-e "s@<NginxServerName>@${NginxServerName}@"  ${currentDir}/nginx/nginx-default.conf.template > /etc/nginx/sites-available/default

mkdir -p ${NginxDocumentRoot}
echo "<?php phpinfo( ); ?>" > ${NginxDocumentRoot}/index.php 


printLog "Apache2 configuration"

cp /etc/apache2/ports.conf /etc/apache2/ports.orig.nginx
sed -e "s/<ApachePort>/8080/" \
-e "s/<ApacheHTTPSport>/8443/" ${currentDir}/apache2/apache2-ports.conf.template   > /etc/apache2/ports.conf

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.orig.nginx
sed -e "s/<ApachePort>/8080/" \
-e "s@<ApacheDocumentRoot>@${NginxDocumentRoot}@" \
-e "s@<ApacheServerName>@127.0.0.1@" ${currentDir}/nginx/apache2-nginx_conf.template > /etc/apache2/sites-available/000-default.conf

fixPermissions

printLog "REStart Servers"

service apache2 restart 
service nginx restart
