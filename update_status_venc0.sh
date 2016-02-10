#!/bin/bash
for ROOM in aw1120 aw1121 aw1124 aw1125 aw1126 ; do
  ~/videobox/count_talks.sh $ROOM | sort > ~/storage/rsync_to_video_fosdem_org/$ROOM/STATUS.TXT
done

