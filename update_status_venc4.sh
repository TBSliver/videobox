#!/bin/bash
for ROOM in ua2114 ua2220 ub2252a ud2120 ud2218a ; do
  ~/videobox/count_talks.sh $ROOM | sort > ~/storage/rsync_to_video_fosdem_org/$ROOM/STATUS.TXT
done

