#!/bin/bash

##################################################################
#
#    Cyclist Obscura - Video Processing
#
#    file       : youtube_deliverable.sh
#    date       : 07/09/2018
#    depends    : BASH, FFmpeg
#    licence    : GPL v3.0
#    further details from:
#       https://support.google.com/youtube/answer/1722171?hl=en-GB
#
##################################################################

MASTER_VIDEO=$1
OUTPUT_VIDEO=${MASTER_VIDEO%.*}-youtube.mp4

echo "##################################################################"
echo "Youtube Deliverable"
echo "v 1.0  09/09/2018"
echo "##################################################################"
echo $MASTER_VIDEO $OUTPUT_VIDEO
echo ""

echo "Pass 1"
ffmpeg -i $MASTER_VIDEO -pass 1 -vf scale=1920:1080:0 -sws_flags lanczos \
 -c:v libx264 -b:v 18M -profile:v high -g 25 -bf 2 -b_strategy 2 -refs 8 \
 -me_method umh -me_range 128 -f mp4 -an /dev/null
echo "##################################################################"
echo "Pass 2"
ffmpeg -i $MASTER_VIDEO -pass 1 -vf scale=1920:1080:0 -sws_flags lanczos \
 -movflags +faststart -c:a libfdk_aac -ar 48000 -b:a 384k -c:v libx264 -b:v 18M \
 -profile:v high -g 25 -bf 2 -b_strategy 2 -refs 8 -me_method umh -me_range 128 \
 -f mp4 $OUTPUT_VIDEO
echo "##################################################################"
