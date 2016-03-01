#!/bin/bash

#Loops over all talks in ~/videobox/schedule and prints lines with status information.
#Usage: count_talks.sh ROOMNAME

ROOM=$1

#grep -A 15 -B 15 ROOM=\'ua2114\' ./* | grep LOST | wc -l

for i in `grep -l "ROOM='${ROOM}'" ~/videobox/schedule/*`; do

  TITLE=$(grep TITLE $i);

  OUT_DIR='/home/fosdem/storage/rsync_to_video_fosdem_org'
  OUT_FILE=$(echo ${TITLE:6} | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)
  FILENAME="${OUT_DIR}/${ROOM}/${OUT_FILE}.mp4"

  if [ -e $FILENAME ] ; then
    RDY=""
  else
    RDY="NOT AVAILABLE YET - WILL BE FIXED ASAP (`basename $i`) - "
  fi

  if grep WEBMONLY $i > /dev/null; then echo "OK: ${RDY}${TITLE:6}"; continue; fi

  if grep NOAUDIO $i > /dev/null; then echo "LOST: (no audio) ${TITLE:6}"; continue; fi
  if grep LOST $i > /dev/null; then echo "LOST: ${TITLE:6}"; continue; fi
  if grep NOSLIDES $i > /dev/null; then echo "PARTIAL: ${RDY}(no slides) ${TITLE:6}"; continue; fi
  if grep "NO SLIDES" $i > /dev/null; then echo "PARTIAL: ${RDY}(no slides) ${TITLE:6}"; continue; fi
  if grep PARTIAL $i > /dev/null; then echo "PARTIAL: ${RDY}${TITLE:6}"; continue; fi

  if grep -E '^CAM_END=$' $i >/dev/null; then echo "UNKNOWN: ${TITLE:6}"; continue; fi;

  echo "OK: ${RDY}${TITLE:6}"
done

