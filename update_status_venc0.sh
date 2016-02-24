#!/bin/bash
for ROOM in aw1120 aw1121 aw1124 aw1125 aw1126 h2214 h2215 janson k1105 ua2114 ua2220 ub2252a ud2120 ud2218a ; do
  ~/videobox/count_talks.sh $ROOM | sort > ~/storage/rsync_to_video_fosdem_org/$ROOM/STATUS.TXT
done

