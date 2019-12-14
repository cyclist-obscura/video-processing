#!/bin/bash

# Requires Imagemagick 7.0 latest version

LUTFILE=$1
BITDEPTH=$2

FILEOUT=${LUTFILE%.cube}_$BITDEPTH.png

magick cube:$LUTFILE[$BITDEPTH] $FILEOUT
