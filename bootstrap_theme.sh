#! /usr/bin/env bash

read_name () {
	echo "Pleas, enter the domain name of your web page: "
	read fqdn
	if [ -z "$fqdn" ];
	then
		echo "A non-empty domain is required."
		fqdn
	fi
}

name_validation () {
	echo "Bind the underscores theme to "$(tput bold)$fqdn$(tput sgr0)" domain name and bootstrap it? [S/n]"
	read agreement
	if [ -z "$agreement" ] || [ "$agreement" = "s" ] || [ "$agreement" = "S" ]; then
		echo "Bootstraping"
	else
		echo "Bye bye"
		exit 1
	fi
}

install_wp () {
    echo "Downloading wordpress source base"
    mv src _src \
        && wget https://wordpress.org/latest.zip \
        && unzip latest.zip \
        && mv wordpress src \
        && rm latest.zip \
        && mv _src src/wp-content/themes/$fqdn
}

read_name
name_validation

find src -type f -exec sed -i -e "s/'_s'/'$fqdn'/g" {} \;
find src -type f -exec sed -i -e "s/_s_/$fqdn_/g" {} \;
sed -i -e "s/Text Domain: _s/Text Domain: $fqdn/g" src/style.css
find src -type f -exec sed -i -e "s/ _s/ $fqdn/g" {} \;
find src -type f -exec sed -i -e "s/_s-/$fqdn-/g" {} \;
find src -type f -exec sed -i -e "s/_S_/${fqdn^^}_/g" {} \;
sed -i -e "s/fqdn/$fqdn/g" Dockerfile

install_wp

echo "Your enviornment is ready to go!"

# cd src && composer install && npm install
