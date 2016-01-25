
#!/usr/local/bin/bash

#PRES_FILE="$1"
#PRES_SEEK=0
#CAM_FILE="$2"
#CAM_SEEK=0
#OUT_FILE="meh.mp4"
#DURATION=300
#TITLE="Test talk"
#SUBTITLE="jjjjjj a talk to demonstrate the compositing setup"
#SPEAKERS="Niels"

if [ ! -f finished/${OUT_FILE} ] ; then

ffmpeg -y -i video/bg.jpg -filter_complex '[0:0]
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Light.otf:fontsize=16:x=0.5*lh:y=H-2.5*lh:textfile=video/copyright,
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Black.otf:fontsize=20:x=16:y=8:text='"$TITLE"',
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Light.otf:fontsize=16:x=16:y=28:text='"$SUBTITLE"',
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Roman.otf:fontsize=16:x=16:y=44:text='"$SPEAKERS"' [mainv]' -map '[mainv]' finished/${OUT_FILE}.png

sleep 1

ffmpeg -y -loglevel verbose \
 -loop 1 -i video/preroll-%d.jpg \
 -loop 1 -i finished/${OUT_FILE}.png \
 -loop 1 -i video/postroll-%d.jpg \
 -ss ${PRES_SEEK} -t ${DURATION} -i ${PRES_FILE} \
 -ss ${CAM_SEEK} -t ${DURATION} -i ${CAM_FILE}  \
-filter_complex '[0:0] setsar=1/1, trim=end=5 [preroll];
[2:0] setsar=1/1, trim=end=5 [postroll];
aevalsrc=0:d=1 [silence_pre];
aevalsrc=0:d=1 [silence_post];
[4:1] asetpts=PTS-STARTPTS, channelmap=map=FL|FL [maina];
[1:0] setsar=1/1, setpts=PTS-STARTPTS [bg];
[3:0] setpts=PTS-STARTPTS, scale=800:600 [pres];
[4:0] setpts=PTS-STARTPTS, scale=490:368, crop=368:368:61:0 [cam];
[bg_c][pres] overlay=x=16:y=64:eof_action=endall [bg_pc];
[bg][cam] overlay=x=864:y=296 [bg_c];
[preroll][silence_pre] [bg_pc][maina] [postroll][silence_post] concat=n=3:v=1:a=1 [outv][outa]' \
 -map '[outv]' -map '[outa]' \
 -pix_fmt yuv420p \
 -vcodec libx264 -crf 22 -preset ultrafast -acodec aac -aq 80 -strict -2 finished/${OUT_FILE}

#compand=attacks=5:decays=10:volume=-20:points=-90/-90|-40/-20|0/-10:delay=5

fi
