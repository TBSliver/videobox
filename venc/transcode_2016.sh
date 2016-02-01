#! /bin/bash

verbose=0
OUT_DIR='/home/fosdem/storage/rsync_to_video_fosdem_org'
ROOMS=(aw1120 aw1121 aw1124 aw1125 aw1126 h1301 h1302 h1308 h1309 h2213 h2214 h2215 janson k1105 k3201 k3401 k4201 k4401 k4601 ua2114 ua2220 ub2252a ud2120 ud2218a)

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            printf 'EXAMPLE: time ./transcode_2016.sh --camera /tmp/cam.mp4 --cameraseek 0 --room aw1120 --slides /tmp/slides.mp4 --slidesseek 5 --speakers '"'"'Mark Van den Borre en Ieva Supjeva'"'"' --title '"'"'De Bourgondische höfkapel in de 14e eeuw.'"'\n" >&1
            exit
            ;;
	# Camera file
        -c|--camera)
            if [ -n "$2" ]; then
                CAM_FILE=$2
                shift
            else
                printf 'ERROR: "--camera" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --camera=?*)
            CAM_FILE=${1#*=}
            ;;
        --camera=)
            printf 'ERROR: "--camera" requires a non-empty option argument.\n' >&2
            exit 1
            ;;

	# Camera seek (optional)
        -cs|--cameraseek)
            if [ -n "$2" ]; then
                CAM_SEEK=$2
                shift
            else
                printf 'ERROR: "--cameraseek" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --cameraseek=?*)
            CAM_SEEK=${1#*=}
            ;;
        --cameraseek=)
            printf 'ERROR: "--cameraseek" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
	# Duration in seconds (optional)
        -d|--duration)
            if [ -n "$2" ]; then
                DURATION=$2
                shift
            else
                printf 'ERROR: "--duration" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --duration=?*)
            CAM_FILE=${1#*=}
            ;;
        --duration=)
            printf 'ERROR: "--duration" requires a non-empty option argument.\n' >&2
            exit 1
            ;;


	# Room name
        -r|--room)
            if [ -n "$2" ]; then
                ROOM=$2
                shift
            else
                printf 'ERROR: "--room requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --room=?*)
            ROOM=${1#*=}
            ;;
        --room=)
            printf 'ERROR: "--room" requires a non-empty option argument.\n' >&2
            exit 1
            ;;

	# Slides file
        -s|--slides)
            if [ -n "$2" ]; then
                PRES_FILE=$2
                shift
            else
                printf 'ERROR: "--slides" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --slides=?*)
            PRES_FILE=${1#*=}
            ;;
        --slides=)
            printf 'ERROR: "--slides" requires a non-empty option argument.\n' >&2
            exit 1
            ;;

	# Slides seek 
        -ss|--slidesseek)
            if [ -n "$2" ]; then
                PRES_SEEK=$2
                shift
            else
                printf 'ERROR: "--slidesseek" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --slidesseek=?*)
            PRES_SEEK=${1#*=}
            ;;
        --slidesseek=)
            printf 'ERROR: "--slidesseek" requires a non-empty option argument.\n' >&2
            exit 1
            ;;

	# Speakers
        -sp|--speakers)
            if [ -n "$2" ]; then
                SPEAKERS=$2
                shift
            else
                printf 'ERROR: "--speakers" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --speakers=?*)
            SPEAKERS=${1#*=}
            ;;
        --speakers=)
            printf 'ERROR: "--speakers" requires a non-empty option argument.\n' >&2
            exit 1
            ;;

	# Title
        -t|--title)
            if [ -n "$2" ]; then
                TITLE=$2
		echo "Title is $TITLE"
                shift
            else
                printf 'ERROR: "--title" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --title=?*)
            TITLE=${1#*=}
            ;;
        --title=)
            printf 'ERROR: "--title" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
        -v|--verbose)
            verbose=$((verbose + 1)) # Each -v argument adds 1 to verbosity.
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac

    shift
done

# Sanity checks: do the vars we need exist?
if [ -z "$CAM_FILE" ]; then
    printf 'ERROR: option "--camera FILE" not given. See --help.\n' >&2
    exit 1
fi
if [ -z "$ROOM" ]; then
    printf 'ERROR: option "--room" not given. See --help.\n' >&2
    exit 1
fi
if [ -z "$PRES_FILE" ]; then
    printf 'ERROR: option "--slides" not given. See --help.\n' >&2
    exit 1
fi
if [ -z "$SPEAKERS" ]; then
    printf 'ERROR: option "--speakers" not given. See --help.\n' >&2
    exit 1
fi
if [ -z "$TITLE" ]; then
    printf 'ERROR: option "--title" not given. See --help.\n' >&2
    exit 1
fi


# Sanity check: do the rooms exist? TODO: somewhat naive matching
if ! [[ ${ROOMS[*]} =~ "$ROOM" ]]; then
    printf 'ERROR: option "--room" not valid. Please use a valid room name.\n' >&2
    exit 1
fi

# For these, it's not a problem if they're not set
if [ -z "$PRES_SEEK" ]; then
    PRES_SEEK=0
fi
if [ -z "$CAM_SEEK" ]; then
    CAM_SEEK=0
fi
if [ -z "$DURATION" ]; then
    DURATION=$(ffprobe -i ${CAM_FILE} -show_entries format=duration -v quiet -of  csv="p=0")
fi

# Slugify title
OUT_FILE=$(echo $TITLE | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)

if [ ! -f ${OUT_DIR}/${ROOM}/${OUT_FILE} ] ; then

# Create background file with title embedded in it
ffmpeg -y -i video/bg.jpg -filter_complex '[0:0]
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Light.otf:fontsize=16:x=0.5*lh:y=H-2.5*lh:textfile=video/copyright,
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Black.otf:fontsize=20:x=16:y=8:text='"$TITLE"',
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Light.otf:fontsize=16:x=16:y=28:text='"$SUBTITLE"',
  drawtext=expansion=none:borderw=2:fontcolor=#ffffff:fontfile=video/font/Roman.otf:fontsize=16:x=16:y=44:text='"$SPEAKERS"' [mainv]' -map '[mainv]' ${OUT_DIR}/${ROOM}/${OUT_FILE}.png

sleep 1

ffmpeg -y -loglevel verbose \
 -loop 1 -i video/preroll.jpg \
 -loop 1 -i ${OUT_DIR}/${ROOM}/${OUT_FILE}.png \
 -loop 1 -i video/postroll.jpg \
 -ss ${PRES_SEEK} -t ${DURATION} -i ${PRES_FILE} \
 -ss ${CAM_SEEK} -t ${DURATION} -i ${CAM_FILE}  \
-filter_complex '[0:0] setsar=1/1, trim=end=5 [preroll];
[2:0] setsar=1/1, trim=end=5 [postroll];
aevalsrc=0:d=1 [silence_pre];
aevalsrc=0:d=1 [silence_post];
[4:1] asetpts=PTS-STARTPTS, channelmap=map=FL|FL [maina];
[1:0] setsar=1/1, setpts=PTS-STARTPTS [bg];
[3:0] setpts=PTS-STARTPTS, scale=800:450 [pres];
[4:0] setpts=PTS-STARTPTS, scale=544:306:force_original_aspect_ratio=1 [cam];
[bg_c][pres] overlay=x=0:y=64:eof_action=endall [bg_pc];
[bg][cam] overlay=x=736:y=414 [bg_c];
[preroll][silence_pre] [bg_pc][maina] [postroll][silence_post] concat=n=3:v=1:a=1 [outv][outa]' \
 -map '[outv]' -map '[outa]' \
 -pix_fmt yuv420p \
 -vcodec libx264 -crf 22 -threads 6 -preset ultrafast -acodec aac -aq 80 -strict -2 \
 -movflags +faststart ${OUT_DIR}/${ROOM}/${OUT_FILE}.mp4

#compand=attacks=5:decays=10:volume=-20:points=-90/-90|-40/-20|0/-10:delay=5

fi
