#!/bin/bash
function getAndSet (){ # Takes 2 args, number and local addr
	i=$1

	while [ $i -lt 10 ]; do
		# Xpath takes attribute "href" from "entry" number $i
		XPATH="string(//entry[position()=$i]/link[@rel='enclosure']/@href)"

		# Flickr provides thumbnail in feed "_b.jpg". We want hi-res "_h.jpg"
		THUMB=`xpath -q -e "$XPATH" $FEED`
		URL=${THUMB/"_b.jpg"/"_h.jpg"}

		# Local file name is iso-date + use, eg. "2017-04-28--12-00-background.jpg"
		BASENAME=`date +%F--%H-%I-$2`
		FILENAME="/home/rasmus/Documents/RasmusTweaks/DesktopFlickr/$BASENAME.jpg"
		curl -s $URL -o "$FILENAME"

		# Is it big enough & is it landscape or portrait?
		W=`identify -format "%[fx:w]" "$FILENAME"`
		H=`identify -format "%[fx:h]" "$FILENAME"`

		# The big enough-breaker. Could just be width.
		if [ $W -lt $MINSIZE -a $H -lt $MINSIZE ]; then i=$[$i+1]; continue; fi

		if [ $W -ge $H ]; then
			# Landscape or square
			POPTION="wallpaper"
		else
			# Portrait
			POPTION="zoom"
		fi
		# Set and break. No need to update if nothing adequate is available
		gsettings set org.gnome.desktop.$2 picture-uri "$FILENAME"
		gsettings set org.gnome.desktop.$2 picture-options "$POPTION"
		break
	done
}

# Minimum size. 1366 px chosen because of my display resolution
MINSIZE=1366

# xpath only accepts a file-path, so temp file needed.
FEED="flickrTEMP.xml"
curl -s 'https://api.flickr.com/services/feeds/photos_public.gne?tags=europe,nature' -o $FEED

getAndSet 1 "background"
getAndSet 2 "screensaver"

# Clear temp file
rm -rf $FEED
