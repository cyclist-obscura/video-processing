#!/bin/bash

##################################################################
#
#    Cyclist Obscura - Video Processing
#
#    file       : dvd_deliverable.sh
#    date       : 07/09/2018
#    depends    : BASH, FFmpeg
#    licence    : GPL v3.0
#    further details from:
#       https://melodiefabriek.com/blog/loudness/
#
##################################################################

MASTER_VIDEO=$1
OUTPUT_VIDEO=${MASTER_VIDEO%.*}-dvd-pal.m2v

echo "##################################################################"
echo "DVD Deliverable"
echo "v 1.0  09/09/2018"
echo "##################################################################"
echo $MASTER_VIDEO $OUTPUT_VIDEO
echo ""


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# >>                             Rate control settings
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Medium bitrate (b)
E_BR=4500k
# Maximum Bitrate (maxrate) (Use 9800k max for DVD compatibility)
VBV_MBR=9800k
# Maximum buffer size (bufsize) (Use 1835k max for DVD compatibility)
VBV_MBS=1835k
# Fixed quality VBR (q) (Fishman0919's suggestion)
E_FQ=2.0
# Minimum quantizer (qmin) (2 is good value for low bitrate, b<=1800k)
E_MQ=1.0
# Minimum frame-level Lagrange multiplier (lmin) [0.01;255.0] (Fishman0919 suggests a value of 0.75)
E_MLM=0.75
# Minimum macroblock-level Lagrange multiplier (mblmin) [0.01;255.0] (Fishman0919 suggests a value of 50.0)
E_MBL=50.0
# Quantizer variability (qcomp) [0.00;1.00] (0.75 is good value) (Fishman0919 suggests a value of 0.7)
E_VQ=0.70


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# >>                                   GOP structure
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Maximum interval of I-frames or Keyframes (g) (Use 15 for DVD PAL, 18 for DVD NTSC, 12 for Pulldown)
E_MIK=15
# Maximum number of B-frames (bf) [0;4] (Use 2 for DVD compatibility)
E_MBF=2
# Adaptive B-Frames strategy (b_strategy) [0;2] (Pass one only, 0 is deactivated, 1 is fast and 2 is slow. Fishman0919 suggests a value of 2)
E_ABF=2
# Slow adaptive refinement of B-frames (brd_scale) [0;3] (0 is full search, higher is faster; only valid if b_strategy=2. Fishman0919 suggests a value of 2)
E_SBF=1
# Motion detection for B-frames (b_sensitivity) [>0] (Only valid if b_strategy=1)
E_DBF=40
# Threshold for scene change detection (sc_threshold) [−1000000000;1000000000] (Negative values indicate that it is more likely to insert an I-frame when it detects a scene change)
E_TSD=-30000

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# >>                    Motion estimation settings
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Range for motion estimation (me_range) [0;9999]
E_RME=512
# Optimization of rate distortion (mbd) [0;2] (2 is the best value)
E_RDO=2
# Diamond size (and pre-pass too) (dia_size, pre_dia_size) [-99;6] (Negative values are for adaptive diamond)
E_DIA=-4
# Comparison function for the macroblock decision (mbcmp) [0;2000] (0 is SAD, 1 is SSE2, 2 is SADT, +256 for chroma motion estimation, currently does not work (correctly) with B-frames)
E_CMB=2
# Comparison function for pre pass, full, and sub motion estimation (precmp, subcmp, cmp) [0;2000] (0 is SAD, 1 is SSE2, 2 is SADT, +256 for chroma motion estimation, currently does not work (correctly) with B-frames)
E_CMP=2
# Comparison function for frame skip (skip_cmp) [0;2000] (0 is SAD, 1 is SSE2, 2 is SADT, +256 for chroma motion estimation, currently does not work (correctly) with B-frames)
E_CMS=2
# Estimation of previous movement (preme) [0;2]
E_PME=2
# Amount of motion predictors (last_pred) [0;99]
E_AMP=2

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# >>                                    Other settings
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Aspect Ratio (aspect) (4/3 or 16/9 for DVD compatibility)
E_DAR=16/9
# Frame size (s) (b up to 2500 kbps =>s=704x480 (NTSC), b greater than 2500 kbps =>s=720x480 (NTSC))
E_SZE=720x576
# Frame rate (r) (use 25 for PAL, 24000/1001 or 30000/1001 para NTSC)
E_FPS=25
# DC precision (dc) [8;10] (b up to 1800k =>dc=8, between 1800k and 3500k =>dc=9, greater than 3500k =>dc=10)
E_DC=10
# Matrices
E_INTRA=08,08,09,09,10,10,11,11,08,09,09,10,10,11,11,12,09,09,10,10,11,11,12,12,09,10,10,11,11,12,13,13,10,10,11,11,12,13,13,14,10,11,11,12,13,13,14,15,11,11,12,13,13,14,15,15,11,12,12,13,14,15,15,16
E_INTER=08,08,09,09,10,10,11,11,08,09,09,10,10,11,11,12,09,09,10,10,11,11,12,12,09,10,10,11,11,12,13,13,10,10,11,11,12,13,13,14,10,11,11,12,13,13,14,15,11,11,12,13,13,14,15,15,11,12,12,13,14,15,15,16


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# >>                                   FFMPEG CLI
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

echo "Pass 1"
ffmpeg -i $SRC -pass 1 -passlogfile Pass.log -vf scale=720:576:0 -sws_flags lanczos -vcodec mpeg2video -maxrate $VBV_MBR -bufsize $VBV_MBS -g $E_MIK -bf $E_MBF -bidir_refine 0 -b_strategy $E_ABF -brd_scale $E_SBF -b_sensitivity $E_DBF -dc $E_DC -q:v $E_FQ -intra_vlc true -intra_matrix $E_INTRA -inter_matrix $E_INTER -an -f mpeg2video -y 1st-pass.mpg
echo "##################################################################"
echo "Pass 2"
ffmpeg -i $SRC -pass 2 -passlogfile Pass.log -vf scale=720:576:0 -sws_flags lanczos -vcodec mpeg2video -b:v $E_BR -maxrate $VBV_MBR -bufsize $VBV_MBS -g $E_MIK -bf $E_MBF -bidir_refine 0 -sc_threshold $E_TSD -sc_factor 4 -b_sensitivity $E_DBF -me_range $E_RME -mpv_flags mv0+naq -mv0_threshold 0 -mbd $E_RDO -mbcmp $E_CMB -precmp $E_CMP -subcmp $E_CMP -cmp $E_CMP -skip_cmp $E_CMS -dia_size $E_DIA -pre_dia_size $E_DIA -preme $E_PME -last_pred $E_AMP -dc $E_DC -lmin $E_MLM -mblmin $E_MBL -qmin $E_MQ -qcomp $E_VQ -intra_vlc true -intra_matrix $E_INTRA -inter_matrix $E_INTER -f mpeg2video -color_primaries 5 -color_trc 5 -colorspace 5 -color_range 1 -aspect $E_DAR -f m2v -y $OUT
echo "##################################################################"

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# >>                                   TIDY UP
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

rm Pass* 1st-pass.mpg
