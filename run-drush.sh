#!/bin/bash


currentDir=$(dirname ${BASH_SOURCE[0]})

# Load variables, functions and properties
. ${currentDir}/linuxServers.properties
. ${currentDir}/varsAndFuncs.sh



printLog "Packages Install"
apt-get install -y ${installPackagesDrush}

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
composer

composer ${drush7Version}

export PATH="$HOME/.composer/vendor/bin:$PATH"
echo 'PATH="$HOME/.composer/vendor/bin:$PATH"' > ~/.bashrc

composer global update