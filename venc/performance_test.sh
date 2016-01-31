#! /bin/bash

./transcode_2016.sh --camera /tmp/cam.mp4 --room aw1120 --slides /tmp/slides.mp4 --speakers 'Mark Van den Borre en Ieva Supjeva' --title 'De Bourgondische höfkapel\ in " de 14e eeuw' &
./transcode_2016.sh --camera /tmp/cam1.mp4 --room aw1121 --slides /tmp/slides1.mp4 --speakers 'Mark Van den Borre en Ieva Supjeva' --title 'De Bourgondische höfkapel\ in " de 14e eeuw' &
./transcode_2016.sh --camera /tmp/cam2.mp4 --room aw1124 --slides /tmp/slides2.mp4 --speakers 'Mark Van den Borre en Ieva Supjeva' --title 'De Bourgondische höfkapel\ in " de 14e eeuw' &
./transcode_2016.sh --camera /tmp/cam3.mp4 --room aw1125 --slides /tmp/slides3.mp4 --speakers 'Mark Van den Borre en Ieva Supjeva' --title 'De Bourgondische höfkapel\ in " de 14e eeuw' &
./transcode_2016.sh --camera /tmp/cam4.mp4 --room aw1126 --slides /tmp/slides4.mp4 --speakers 'Mark Van den Borre en Ieva Supjeva' --title 'De Bourgondische höfkapel\ in " de 14e eeuw'

wait
echo "Finished. Yay!"
