#!/bin/bash
for ROOM in h1301 h1302 h1308 h1309 h2213 k3201 k3401 k4201 k4401 k4601 ; do
  ~/videobox/count_talks.sh $ROOM | sort > ~/storage/rsync_to_video_fosdem_org/$ROOM/STATUS.TXT
done

