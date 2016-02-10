#!/bin/bash
for ROOM in h1301 h1302 h1308 h1309 h2213 ; do
  ~/videobox/count_talks.sh $ROOM | sort > ~/storage/rsync_to_video_fosdem_org/$ROOM/STATUS.TXT
done

