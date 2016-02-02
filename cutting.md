A short guide to cutting videos for FOSDEM 2016
===============================================

Prerequisites
-------------

* A video player that shows seconds since the start of the file (I use either mplayer or mpv --term-status-msg '  ${=time-pos}')
* Access to the cutting piratepad (given by the fosdem-video team)
* Access to the raw videos (given by the fosdem-video team)
* The FOSDEM schedule at https://fosdem.org/2016/schedule/
* A checkout of the videobox repo
* A good time difference calculator (I used http://www.grun1.com/utils/timeDiff.cfm)
* A good calculator for normal numbers (I used bc)


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

The cam files are the recordings from the camera in the room, and they also have the room audio. The slides files contain the recordings from the screen and audio of the presenter's laptop. The file names are in the format `YY-mm-DD_HHMMSS.ts`, where:
* YY - year
* mm - month
* DD - day
* HH - hours
* MM - minutes
* SS - seconds

The hour/minute/second part of the timestamp plays a big role in the cutting.

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

and after:

```
OB_ID=4627

CAM_END=6919
CAM_START=5362
CAM_FILE='16-01-30_163715.ts'
CAM_SEEK=0 # optional
CAM_STREAM='https://stream-a.fosdem.org/'

PRES_END=22618
PRES_SEEK=0 #optional
PRES_FILE=16-01-30_121252.ts
PRES_START=21061
PRES_STREAM='https://stream-a.fosdem.org/'

ROOM='aw1124'

TITLE='A Command-Line Driver Generator'
SPEAKERS='Jacob Sparre Andersen'
```

There are two sets of fields you have to fill, for both the camera and the presenters stream:
* CAM_FILE, PRES_FILE - the file name of the file this will be cut from
* CAM_START, PRES_START - the beginning of the cut, in seconds from the start of the file
* CAM_END, PRES_END - the end of the cut, in seconds from the start of the file

Cutting process
---------------

First, download the cam/slides files for the room/day in question and open the schedule for the room.

For all talks that are not recorded (e.g. they start before the first recording available for the room) add a comment in the file at the end, `# LOST` (see for example 3814.txt).

Calculate the time difference between the first slides and first video file (this you'll have to do for the rest, too). For example, in the H.1302 case above:
* CAM: 16-01-30_121527.ts PRES: 16-01-30_121549.ts -> -22 seconds
* CAM: 16-01-30_123152.ts PRES: 16-01-30_121549.ts -> 963 seconds
* CAM: 16-01-30_183503.ts PRES: 16-01-30_121549.ts -> 22754 seconds

From this point on, I'll use C as the start of a cam file (timestamp), P as the start of a presentation file (timestamp), LC and LP as their lengths, and TD as the time difference between cam and pres.

(this is the usual case for Saturday, the slides files are unbroken, the camera files have a few pieces)

Note that as the cam files contain the actual audio of the talk, which is most of the useful information in it, they take precedence.

Now, there are a few cases for each talk. Please note that in all cases CAM_END-CAM_START has to be equal to PRES_END-PRES_START:

* Best case scenario - a talk fits in one cam and one pres file. In this case, we watch the cam file, note the start and end of it, and write them to the CAM_START and CAM_END parameters. Then, we write the PRES_START and PRES_END parameters by adding the difference that we calculated before.
* The pres starts a bit after the cam (and there is no other pres file) - then we start the cam at -TD (that's minus TD) and the pres file at 0, and adjust accordingly. The we add a commene below, `# Missing start`
* The cam for a specific talk spans two files - in this case, we first note the gap between the two cam files, let's denote them 1 and 2. It's calculated as C1+LC1-C2, or easier to calculate, C1-C2+LC1 (because we can do C1-C2 in the time calc). For example in the above files, the length of 16-01-30_123152.ts is 21770, so the gap will be 21791-21789, or 2 seconda. We note that in the cutting pirate pad as follows: `h1302cam: 16-01-30_123152 2 16-01-30_183503.ts` . Then, a good person will go, concat the files properly, and you'll get 16-01-30_123152.ts that has the original 16-01-30_123152.ts in it, then 2 seconds of empty video/audio, and then 16-01-30_183503.ts. Then, you can calculate easily CAM_END in the new file.
* More cases to be added.


