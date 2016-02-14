A short guide to cutting videos for FOSDEM 2016
===============================================

Prerequisites
-------------

* A video player that shows seconds since the start of the file. For example one of these:
  * mplayer
  * mpv --term-status-msg '  ${=time-pos}'
  * ffplay
* Access to the cutting piratepad and the raw videos (given by the fosdem-video team)
* The FOSDEM schedule at https://fosdem.org/2016/schedule/
* A checkout of the videobox repo (this repo!)
* A good calculator for normal numbers (e.g. bc or kcalc or similar)


Input files
-----------

The raw videos for each room come in two separate directories, ${ROOMNAME}cam and ${ROOMNAME}slides. This is one example:

```
$ ls -lh h1302*
h1302cam:
total 4.0G
-rw-r--r-- 1 500 500 168M Jan 31 01:47 16-01-30_121527.ts
-rw-r--r-- 1 500 500 3.7G Jan 31 01:53 16-01-30_123152.ts
-rw-r--r-- 1 500 500 155M Jan 31 01:53 16-01-30_183503.ts

h1302slides:
total 5.8G
-rw-r--r-- 1 500 500 5.8G Jan 31 01:56 16-01-30_121549.ts
```

The cam files are the recordings from the camera in the room, and they also have the room audio. The slides files contain the recordings from the screen and audio of the presenter's laptop. The file names are in the format `YY-mm-DD_HHMMSS.ts`, representing the start time of the recording, where:
* YY - year
* mm - month
* DD - day
* HH - hours
* MM - minutes
* SS - seconds


Output file format description
------------------------------

The files you'll have to edit reside in the videobox repo, in schedule/ and look like this, before:

```
OB_ID=4106

CAM_END=
CAM_START=
CAM_FILE=
CAM_SEEK=0 # optional
CAM_STREAM='https://stream-a.fosdem.org/'

PRES_END=
PRES_SEEK=0 #optional
PRES_FILE=
PRES_START=
PRES_STREAM='https://stream-a.fosdem.org/'

ROOM='h2215'

TITLE='Converting LiquidThreads to Flow'
SPEAKERS='Matt Flaschen'
```

You need to fill out the following fields:

```
CAM_END=6919
CAM_START=5362
CAM_FILE='16-01-30_163715.ts'
PRES_END=22618
PRES_FILE=16-01-30_121252.ts
PRES_START=21061
```
There are three sets of fields you have to fill, for both the camera and the presenters stream:
* CAM_FILE, PRES_FILE - the file name of the file this will be cut from in single quotes
* CAM_START, PRES_START - the beginning of the cut, in seconds from the start of the file
* CAM_END, PRES_END - the end of the cut, in seconds from the start of the file

Everything else can be left as-is, but __you may need to add some extra lines__:
* For talks where there is no recording, add `#LOST`
* Missing audio? `#NOAUDIO`
* Missing slides? `#NOSLIDES`
* For partial footage put `#PARTIAL`  (`#NOSLIDES` is automatically marked as partial already)
* If the RIGHT audio channel contains the best audio, add a line `AUDIO="FR-FL|FR-FR"`. For the LEFT channel, add nothing.

Cutting process
---------------

Pick a room on the piratepad that doesn't have a name behind it yet. __Put your name there to indicate you're working on it, and set the status to PROCESSING as well.__
Then, download the cam/slides files for the room/day in question and open the schedule for the room.

For all talks that are not recorded or otherwise missing add a comment in the file at the end, `#LOST` (see for example 3814.txt).

Run the stitching script on the material you downloaded ( https://raw.githubusercontent.com/FOSDEM/videobox/master/stitch.sh ). Say yes to remuxing the files, and if you want to trade CPU cycles for less human work, also let it stitch the files. This last part is not needed to do the actual stitching, though.

The script will output start/duration/end times for all files and tell you what number to add to talks that start in that file to get the correct start/end points in the stitched file.

Take the difference between the cam and slides start times and make note of it. If the slides started later than cam, substract the difference for the PRES lines. If the slides started earlier, add the difference instead.

Please note that in all cases CAM_END-CAM_START has to be equal to PRES_END-PRES_START.

* Best case scenario - a talk fits in one cam and one pres file. In this case, we watch the cam file, note the start and end of it, and write them to the CAM_START and CAM_END parameters. Then, we write the PRES_START and PRES_END parameters by adding or subtracting the difference that we calculated before.
* The pres starts a bit after the cam (and there is no other pres file) - then we start the cam at -TD (that's minus TD) and the pres file at 0, and adjust accordingly. Also add a line saying `#PARTIAL` to indicate partial footage.
* The reverse works the same, but then the PRES_START is negative, instead.
* Either cam or slides is split over multiple files. This is what the stitching script is for. It will create a new file that contains all the footage of the separate files you feed the script, with correctly timed black sections in between to fill in the gaps. As filename, use the FIRST filename from the to-be-stitched footage, and pretend it contains all material without break. If you have trouble with the math for this, simply let the stitching script do the stitch encode locally and use the times from the resulting file. __Make sure to note in the piratepad in the section "WAITING MERGES:" which files need to be merged.__

When done with a room-day, note it as `DONE` in the piratepad. Then: wash, rinse, repeat.

Confused? Look at examples from rooms that have already been cut.
