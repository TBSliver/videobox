#!/bin/bash
for ROOM in h2214 h2215 janson k1105 ; do
  ~/videobox/count_talks.sh $ROOM | sort > ~/storage/rsync_to_video_fosdem_org/$ROOM/STATUS.TXT
done

