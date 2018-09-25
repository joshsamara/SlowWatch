#!/usr/bin/env bash
# Build script (only really setup to run in this dir)
# TODO:

# Load vars from this file
source ./buildvars

java \
-Dfile.encoding=UTF-8 \
-Dapple.awt.UIElement=true \
-jar $BRAINS_PATH \
-o ./bin/SlowWatch.prg \
-w \
-y $KEY_PATH \
-d vivoactive3_sim \
-s 2.3.0 \
-f monkey.jungle
