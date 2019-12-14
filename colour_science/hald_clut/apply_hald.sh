#!/bin/bash

###########################################################################
# HALD CLUT
# File              : apply_hald.sh
# Date				      : 23/09/19
# Author  			    : Simon Thompson
# Requires 			    : Imagemagick 7.0 latest version
#                   : Bash
# Usage				      : <image file> <hald file>
# Output			      : PNG FILE WITH COLOUR ADJUsTED
###########################################################################

IMFILE=$1
LUTFILE=$2

FILEOUT=${IMFILE%.%}_${LUTFILE%.png}.png

magick $IMFILE $LUTFILE -hald-clut $FILEOUT
