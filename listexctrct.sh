#!/usr/bin/env bash -x

#run cli command to get the list of the updates objects
#then filter to show only the name of the active plugin that has an update

SITE_PATH=/Applications/MAMP/htdocs/arepo
SITE_URL=http://localhost:8888/arepo/

PLGLIST=$(wp --path=$SITE_PATH  plugin list --status=active --update=available --fields=name --format=json)

#Extrsact the name value from the json and assaign to var array
# //echo "$PLGLIST" | jq -r '.[] | .name'
PLGNAME=$(echo "$PLGLIST" | jq -r '.[] | .name')

echo $PLGNAME

#run the command to update the plugin based on the string
# //wp --path=$SITE_PATH plugin update $PLGNAME

#create a loop to run an update command for each of the plugins name

array=( $PLGNAME )
for i in "${array[@]}"
do
	echo $i
	wp --path=$SITE_PATH plugin update $i
done

# add vr-test to the loop
