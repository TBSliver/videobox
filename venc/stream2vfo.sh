#! /bin/bash

# Live.fosdem.org feeds info about streams: url, start, end, penta
# metadata into a bash file and dumps it onto venc[0-4]. Stream2vgo.sh 
# picks this up and takes care of transcoding and putting it somewhere 
# video.fosdem.org can pick it up through rsync.
#
# BEFORE USE: adjust the CONFIGURATION section
# USAGE: Run this script. Drop a job file (see example) in $MONITORPATH .
#
# Copyright (c) 2016 Mark Van den Borre <mvandenborre@fosdem.org>
#
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# CONFIGURATION
#  modify this to reflect your situation
MONITORPATH='/home/fosdem/jobs/queue'
FINISHEDJOBS='/home/fosdem/jobs/finished'
TMP_DIR='/tmp'

ENCPATH=`dirname "$0"`

mkdir -p $MONITORPATH $FINISHEDJOBS

# Check if we get a file in directory
inotifywait -m $MONITORPATH -e create -e moved_to | while read path action file; do
        echo "File '$file' added to dir '$path' via '$action'"
        #if [[ $file == venc_order*sh ]]; then
		# Load job file
		source $MONITORPATH/$file
		# Set up variables
		#CAM_FILE="$TMP_DIR/CAM_$JOB_ID.mp4"
		#PRES_FILE="$TMP_DIR/PRES_$JOB_ID.mp4"
		TITLE_SANITISED=$(echo $TITLE | sed -r s/[^a-zA-Z0-9]+/\ /g)
		SPEAKERS_SANITISED=$(echo $SPEAKERS|sed -r s/[^a-zA-Z0-9]+/\ /g)
		# Grab the streams. TODO naive, needs parallellising
		#wget "$CAM_STREAM?start=$CAM_START&end=$CAM_END" --output-document=$CAM_FILE
       		#wget "$PRES_STREAM?start=$PRES_START&end=$PRES_END" --output-document=$PRES_FILE
		# Wait until the downloads have finished
		#wait
		let DURATION=${CAM_END}-${CAM_START}
		cam_time=`echo "${CAM_FILE}"|cut -d _ f 1`
		if [ "$cam_time" = "16-01-30" ]; then
			SRCPATH='/home/fosdem/storage/saturday'
		elif [ "$cam_time" = "16-01-31" ]; then
			SRCPATH='/home/fosdem/storage/sunday'
		else
			echo Unknown timestamp in job "$file", cam file "${CAM_FILE}"
			mv $MONITORPATH/$file $FINISHEDJOBS/ 
			continue
		fi
		#${ENCPPATH}/transcode_2016.sh --camera "$CAM_FILE" --cameraseek "$CAM_SEEK" --room "$ROOM" --slides "$PRES_FILE" --slidesseek "$PRES_SEEK"  --title "$TITLE_SANITISED" --speakers "$SPEAKERS_SANITISED" &
		# we need to use the *_START variables instead of the _SEEK ones, as the seek ones are optional and not filled in
		${ENCPATH}/transcode_2016.sh --camera "${SRCPATH}/${ROOM}cam/${CAM_FILE}" --cameraseek "$CAM_START" --room "$ROOM" --slides "${SRCPATH}/${ROOM}slides/${PRES_FILE}" --slidesseek "$PRES_START"  --duration "$DURATION" --title "$TITLE_SANITISED" --speakers "$SPEAKERS_SANITISED" &
		# Don't remove while encoding!
		# rm -rf $CAM_FILE $PRES_FILE
		mv $MONITORPATH/$file $FINISHEDJOBS/ 
	#fi
done                                                
