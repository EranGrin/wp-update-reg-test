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

PS1="⚡"
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
bold=`tput bold`

#Extrsact the name value from the json and assaign to var array
PLGLIST=$(wp --path=$SITE_PATH  plugin list --status=active --update=available --fields=name --format=json)

#array of plugins name
PLGNAME=$(echo "$PLGLIST" | jq -r '.[] | .name')

echo "$(tput setaf 1)AVILABLE UPDATES:\n$(tput sgr0)$(tput setaf 2)$PLGNAME$(tput sgr0)"

# crawl the websit
echo "\n"
echo  👆 would you like to create a new backstop config json file
echo  👆 this will crawl the website dom and create backstop config json file that will $(tput bold)OVERWRITE $(tput sgr0)the present config file
echo  👆 all custom configuration in the config file will be lost
read -p "$(tput setaf 1) $PS1 ! ATTENTION !$(tput sgr 0) Would you like to create a new backstop config json file for $(tput bold)$SITE_NAME$(tput sgr0) [ Y / N ] " -n 1 -r

if [[  $REPLY =~ ^[Yy]$ ]]
  then
    backstop-crawl $SITE_URL -o $SITE_NAME.json
  else
    FILE=$SITE_NAME.json
      if [ ! -f "$FILE" ]; then
      echo "\n"
      echo "\n $(tput setaf 1)$FILE does not exist $(tput sgr0)"
      exit
    fi
fi

# while true; do
#     read -p "$(tput setaf 1)ATTENTION !$(tput sgr 0) Would you like to create a new backstop reference" yn
#     case $yn in
#         [Yy]* ) backstop approve --config $SITE_NAME.json; break;;
#         [Nn]* ) exit;;
#         * ) echo "Please answer yes or no.";;
#       esac
#     done
echo "\n"
read -p "$(tput setaf 1) $PS1 ! ATTENTION ! $(tput sgr 0) Would you like to create a new backstop reference [ Y / N ] " -n 1 -r


if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "\n"
    echo "$(tput setaf 2) $PS1 start the approve procces for the present visual state of the website $(tput sgr 0)"

    backstop approve --config $SITE_NAME.json
fi
# //UPDATERESULT=$(wp --path=$SITE_PATH plugin update --format=json duplicator-pro | jq -r '.[] | .status')
# //echo $UPDATERESULT

#run the command to update the plugin based on the string
# //wp --path=$SITE_PATH plugin update $PLGNAME

#create a loop to run an update command for each of the plugins name

# add vr-test to the loop
echo "\n"
echo " $PS1 Start the loop for plugin update"

array=( $PLGNAME )
for i in "${array[@]}"
 do
  echo "\n"
  echo "$(tput setaf 2) $PS1 start update plugin name:$i $(tput sgr 0)"
  echo "\n"

  UPDATERESULT=$(wp --path=$SITE_PATH plugin update --format=json $i | jq -r '.[] | .status')
    if [ "$UPDATERESULT" == "Error" ];
        then
          echo "\n"
          echo "$(tput setaf 1) $PS1 !! ERROR !! COULD NOT UPDATE: $i $(tput sgr0) script will continue to next update"

        else

          responsefile=$(mktemp -t BKSTOPTEST)
          backstop test --config $SITE_NAME.json >$responsefile &
          pid=$!
          wait $pid
          BKSTOPTEST=$(<$responsefile)
          rm $responsefile

        # if (( input == 0 ));

      if [[ "$BKSTOPTEST" =~ [\berror\b] ]];
          then
              echo "\n"
              read -p "$(tput setaf 1) $PS1 !! ERROR FOUND !! after update:$i do you still like to continue to the next plugin update $(tput sgr0) [ Y / N ] " -n 1 -r

              if [[  $REPLY =~ ^[Yy]$ ]]
                then
                  echo "\n"
                  read -p "$(tput setaf 1) $PS1 ! ATTENTION ! $(tput sgr 0) Would you like to create a new backstop reference [ Y / N ] " -n 1 -r
                  if [[  $REPLY =~ ^[Yy]$ ]]
                      then
                        backstop approve --config $SITE_NAME.json
                      else
                        continue
                    fi
                else
                  exit
              fi

          else
            continue

        fi
    fi
done


### Maybe need to add a kill chromuim as it seeems like the process leave allot of running background processes - killall Chromium
