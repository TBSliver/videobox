#!/bin/bash

#Loops over all talks in ~/videobox/schedule and prints lines with status information.
#Usage: count_talks.sh ROOMNAME

ROOM=$1

#grep -A 15 -B 15 ROOM=\'ua2114\' ./* | grep LOST | wc -l

for i in `grep -l "ROOM='${ROOM}'" ~/videobox/schedule/*`; do

  TITLE=$(grep TITLE $i);

  if grep WEBMONLY $i > /dev/null; then echo "OK: ${TITLE:6}"; continue; fi
  
  if grep NOAUDIO $i > /dev/null; then echo "LOST: (no audio) ${TITLE:6}"; continue; fi
  if grep LOST $i > /dev/null; then echo "LOST: ${TITLE:6}"; continue; fi
  if grep NOSLIDES $i > /dev/null; then echo "PARTIAL: (no slides) ${TITLE:6}"; continue; fi
  if grep "NO SLIDES" $i > /dev/null; then echo "PARTIAL: (no slides) ${TITLE:6}"; continue; fi
  if grep PARTIAL $i > /dev/null; then echo "PARTIAL: ${TITLE:6}"; continue; fi

  if grep -E '^CAM_END=$' $i >/dev/null; then echo "UNKNOWN: ${TITLE:6}"; continue; fi;
    
  echo "OK: ${TITLE:6}"
done

