#! /usr/bin/env bash

read_name () {
	echo "How does your theme is going to be named?"
	read theme_name
	if [ -z "$theme_name" ];
	then
		echo "A non-empty name is required."
		read_name
	fi
}

name_validation () {
	echo "Proceed with bootstraping underscores theme with "$(tput bold)$theme_name$(tput sgr0)" as name? [S/n]"
	read agreement
	if [ -z "$agreement" ] || [ "$agreement" -eq "s" ] || [ "$agreement" -eq "S" ]; then
		echo "Initializing theme"
	else
		echo "Bye bye"
		exit 1
	fi
}

read_name
name_validation

find src -type f -exec sed -i -e "s/'_s'/'$theme_name'/g" {} \;
find src -type f -exec sed -i -e "s/_s_/$theme_name_/g" {} \;
sed -i -e "s/Text Domain: _s/Text Domain: $theme_name/g" src/style.css
find src -type f -exec sed -i -e "s/ _s/ $theme_name/g" {} \;
find src -type f -exec sed -i -e "s/_s-/$theme_name-/g" {} \;
find src -type f -exec sed -i -e "s/_S_/${theme_name^^}_/g" {} \;
sed -i -e "s/theme_name/$theme_name/g" docker-compose.yml

# cd src && composer install && npm install
