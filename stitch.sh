#!/bin/bash

#Script for automatically merging files together and calculating gaps.
#Usage: ./stitch.sh filename1 filename2 [...]
#Will optionally remux first (asks for user input), then print concat-style output for ffmpeg and put this in a concat.txt file.
#Then, optionally, renames the first file to .part if it doesn't already exist and starts the stitching.

#Get duration in seconds for a file
getduration () {
  ffprobe $1 |& grep Duration | cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }'
}

#Get start of file in seconds since beginning of the day
getstart () {
  echo "${1:9:2}*3600+${1:11:2}*60+${1:13:2}" | bc
}

#Gets ffmpeg concat file syntax for merging files
concat_list () {
  #Set to zero to prevent "pre-gap" from printing
  PREVEND=0
  GAP=0

  #Initialize the total duration variable
  TOTALDUR=0

  #Loop over all the filenames
  for FILE; do
   
    #If this was already renamed to .part, use that instead...
    if [ -f ${FILE}.part ] ; then
      FILE=${FILE}.part
    fi

    #Get the file's start, duration and end
    START=`getstart $FILE`
    DUR=`getduration $FILE`
    END=`echo "$START+$DUR" | bc`

    #If we have a previous end (= not the first iteration)
    if [ $PREVEND -gt 0 ]; then
      #And the new file starts after the previous file
      if [ $START -gt $PREVEND ]; then
        #Calculate the gap and print the correct line
        GAP=`echo "$START-$PREVEND" | bc`
        #Calculate new total duration
        TOTALDUR=`echo "$TOTALDUR+$GAP" | bc`
        echo "# Gap is $GAP seconds"
        echo "file 'black${GAP}.ts'"
      else
        #If not, likely something is wrong. Warn the user
        echo "!!WARNING: GAP BETWEEN $PREVFILE AND $FILE IS <= 0!! This is extremely unlikely."
        exit #Cancel rest of operations
      fi
    fi

    #Print the filename in ffmpeg concat syntax
    echo "# start=$START, duration=$DUR, end=$END - add $TOTALDUR to any talks starting in this file"

    if [ $PREVEND -gt 0 ]; then
      echo "file '$FILE'"
    else
      if [ "${FILE: -4}" == "part" ]; then
        echo "file '$FILE'"
      else
        echo "file '$FILE.part'"
      fi
    fi

    #Set previous filename and end time, for next loop iteration
    PREVFILE=$FILE
    PREVEND=$END
    TOTALDUR=`echo "$TOTALDUR+$DUR" | bc`
  done
}

#Shorter version of concat_list function that only creates missing gap files and does nothing more
create_gap_files () {
  PREVEND=0
  GAP=0
  TOTALDUR=0
  for FILE; do
    #If this was already renamed to .part, use that instead...
    if [ -f ${FILE}.part ] ; then
      FILE=${FILE}.part
    fi
    #Get the file's start, duration and end
    START=`getstart $FILE`
    DUR=`getduration $FILE`
    END=`echo "$START+$DUR" | bc`
    #If we have a previous end (= not the first iteration)
    if [ $PREVEND -gt 0 ]; then
      #And the new file starts after the previous file
      if [ $START -gt $PREVEND ]; then
        #Calculate the gap and print the correct line
        GAP=`echo "$START-$PREVEND" | bc`
        if [ ! -f black${GAP}.ts ]; then
          echo "Creating gap file black${GAP}.ts"
          ffmpeg -f lavfi -i aevalsrc=0 -t ${GAP} -s 1280x720 -f rawvideo -pix_fmt rgb24 -r 25 -i /dev/zero -shortest -acodec aac -strict -2 -ar 48k -ac 2 -vcodec h264 black${GAP}.ts
        fi
      fi
    fi
    #Set previous filename and end time, for next loop iteration
    PREVFILE=$FILE
    PREVEND=$END
    TOTALDUR=`echo "$TOTALDUR+$DUR" | bc`
  done
}

read -p "Remux first? (doing this twice will overwrite backup files!) y/n" -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  for FILE; do
    echo "Remuxing $FILE..."
    ffmpeg -i $FILE -c copy remuxed_$FILE >& /dev/null && mv $FILE $FILE.original && mv remuxed_$FILE $FILE && echo "...done"
  done
else
  echo "Not remuxing."
fi

echo "Creating concat.txt file..."
concat_list $@ > concat.txt
#Print the result to the user
cat concat.txt

read -p "Stitch the files now? (takes quite a while!) y/n" -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Stitching now!"
  if [ ! -f ${1}.part ]; then
    echo "${1}.part not found - renaming ${1} to ${1}.part"
    mv ${1} ${1}.part
  fi
  echo "Creating any missing gap files if necessary..."
  create_gap_files $@
  echo "Running ffmpeg. This may take a while."
  ffmpeg -f concat -i ./concat.txt -vcodec h264 -acodec aac -strict -2 $1
else
  echo "Not stitching."
fi

