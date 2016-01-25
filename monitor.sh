#! /bin/bash
#
# Monitor script for throwing videos at encoder boxes
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

# Configuration -- modify this to reflect your situation
# path to monitor
monitorpath="/tmp"
# node prefix
nodeprefix="venc"

# how many encoder nodes in the system
encodernodes=5

# nodecounter keeps track of how many tracks have been thrown at nodes to do a naive distribution
nodecounter=0
# camcounter and slidecounter keep track if we have slide and cam files available for one talk
slidecounter=0 
camcounter=0
# slidefile and camfile keep track of the cam and slide file names for one talk
camfile=""
slidefile=""

# Check if we get a file in directory
inotifywait -m $monitorpath -e create -e moved_to | while read path action file; do
	echo "File '$file' added to dir '$path' via '$action'"
	if [[ $file == *slide.mp4 ]]; then
		slidecounter=$((slidecounter+1))
		slidefile=$file
	fi
	if [[ $file == *cam.mp4 ]]; then
		camcounter=$((camcounter+1))
		camfile=$file
	fi
	if [ "$slidecounter" -gt 0 ] && [ "$camcounter" -gt 0 ];  then
		echo "copying slide file $slidefile to $nodeprefix$((nodecounter%5))"
		scp $path/$slidefile $nodeprefix$((nodecounter%5))
		echo "copying cam file $camfile to $nodeprefix$((nodecounter%5))"
		scp $path/$camfile $nodeprefix$((nodecounter%5))
		nodecounter=$((nodecounter+1))
		slidecounter=0
		camcounter=0
	fi
done
