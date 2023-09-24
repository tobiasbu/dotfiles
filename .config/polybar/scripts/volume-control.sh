#!/bin/sh
# Modified from rufwoof on Puppy Linux forum
# retrieve sndioctl volume level
SNDIO_VALUE=`sndioctl | grep output.level | cut -d "=" -f 2`
SNDIO_VALUE=`printf "%.2f\n" $SNDIO_VALUE`
# adjust VALUE to 0 to 100 with rounded values
YAD_VALUE=`echo $SNDIO_VALUE*100 | bc`
YAD_VALUE=`printf "%.2f\n" "$YAD_VALUE"`
# Feed YAD_VALUE to yad scale and output to sndioctl
yad --scale --window-icon=audio-volume-medium --title="Volume" \
--vertical --on-top \
--width=32 --height=200 --posx=-134 --posy=39 --value=$YAD_VALUE \
--close-on-unfocus --undecorated --no-buttons \
--field="!audio_volume_medium::BTN" \
--print-partial | while read x ; \
do x=`echo "scale=2 ; $x/100" | bc`
  echo $x ; \
done
# sndioctl output.level=$x 1>/dev/null ; \

