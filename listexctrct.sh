#!/usr/bin/env bash -x

#run cli command to get the list of the updates objects
#then filter to show only the name of the active plugin that has an update

#
# SITE_NAME=Arepo
# SITE_PATH=/Applications/MAMP/htdocs/arepo
# SITE_URL=http://localhost:8888/arepo/


SITE_NAME=eulachklinik
SITE_PATH=/Applications/MAMP/htdocs/eulachklinik
SITE_URL=http://localhost:8888/eulachklinik/

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# crawl the websit
echo would you like to create a new backstop config json file
echo this will crawl the website dom and create backstop config json
read -p "$(tput setaf 1)ATTENTION !$(tput sgr 0) Would you like to create a new backstop config json file " -n 1 -r

if [[  $REPLY =~ ^[Yy]$ ]]
  then
    backstop-crawl $SITE_URL -o $SITE_NAME.json
  else
    FILE=$SITE_NAME.json
      if [ ! -f "$FILE" ]; then
      echo "\n $(tput setaf 1)$FILE does not exist \n $(tput sgr 0)"
      exit
    fi
fi


PLGLIST=$(wp --path=$SITE_PATH  plugin list --status=active --update=available --fields=name --format=json)

#Extrsact the name value from the json and assaign to var array
# //echo "$PLGLIST" | jq -r '.[] | .name'
PLGNAME=$(echo "$PLGLIST" | jq -r '.[] | .name')

echo AVILABLE UPDATES: $PLGNAME

read -p "$(tput setaf 1)ATTENTION !$(tput sgr 0) Would you like to create a new backstop reference " -n 1 -r

if [[  $REPLY =~ ^[Yy]$ ]]
  then
    backstop approve --config $SITE_NAME.json

fi

# //UPDATERESULT=$(wp --path=$SITE_PATH plugin update --format=json duplicator-pro | jq -r '.[] | .status')
# //echo $UPDATERESULT

#run the command to update the plugin based on the string
# //wp --path=$SITE_PATH plugin update $PLGNAME

#create a loop to run an update command for each of the plugins name

# array=( $PLGNAME )
# for i in "${array[@]}"
# do
# 	echo $i
# 	wp --path=$SITE_PATH plugin update --format=json $i
# done

# add vr-test to the loop

array=( $PLGNAME )
for i in "${array[@]}"
 do
  echo "$(tput setaf 2)start update plugin name:$i $(tput sgr 0)"
  UPDATERESULT=$(wp --path=$SITE_PATH plugin update --format=json $i | jq -r '.[] | .status')
    if  [ "$UPDATERESULT" == "Error" ]; then

        # echo "test"
        echo "$(tput setaf 1)!! ERROR !! COULD NOT UPDATE: $i(tput sgr 0) script will continue to next update"

      continue

      else

      backstop test --config $SITE_NAME.json

      ##execute the reg-test
      # backstopjs test

      if (( input == 0 ));
        then
          # echo "can continue to the next plugin"
          read -p "$(tput setaf 1)!! ERROR FOUND !! after update:$i $(tput sgr 0) do you still like to continue to the next update plugin" -n 1 -r

          if [[ ! $REPLY =~ ^[Yy]$ ]]
          then exit 1
        fi
      fi
    fi
done
