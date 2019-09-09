#!/bin/bash
set -e


SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PARENT_DIR=$(dirname "$DIR")
source $PARENT_DIR/dist/list_input.sh

website_name=$(cat website_input.json | jq -j --arg c "' " --arg b "'" '$b + .[] .name + $c')


website=( $website_name )
list_input "Which website would you like to Test ?" website selected_website

echo "website: $selected_website"

SITE_NAME=$selected_website
SITE_PATH=$(cat website_input.json | jq -j --arg p "$SITE_NAME" '.[] | select(.name==$p) .path')
SITE_URL=$(cat website_input.json | jq -j --arg p "$SITE_NAME" '.[] | select(.name==$p) .url')



# Need to cehck if the backstop init is already existing otherwise fire the backstop init
# To add a backstop test if this is the first time the website is appprove

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


echo "\n"
read -p "$(tput setaf 1) $PS1 ! ATTENTION ! $(tput sgr 0) Would you like to create a new backstop reference [ Y / N ] " -n 1 -r


if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "\n"
    echo "$(tput setaf 2) $PS1 start the approve procces for the present visual state of the website $(tput sgr 0)"

    backstop approve --config $SITE_NAME.json
fi


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
          continue

        else

          responsefile=$(mktemp -t BKSTOPTEST)
          backstop test --config $SITE_NAME.json >$responsefile &
          pid=$!
          wait $pid
          BKSTOPTEST=$(<$responsefile)
          rm $responsefile

        # if (( input == 0 ));
        echo "$BKSTOPTEST"
      if [[ $BKSTOPTEST =~ error ]];

          then
            echo "error found"
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
