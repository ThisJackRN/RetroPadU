#!/bin/sh
# (c) 2013-09-25, by Wiimm

#------------------------------------------------------------------------------
# settings

SRC_ID=RMCE01
SRC_TYPE=USA

DEST_ID=RMCETO
DEST_NAME="Mario Kart Retro Rewind"

IMAGE_TYPE=wbfs

#------------------------------------------------------------------------------
# job

rm -rf workdir.tmp
wit extract . --DEST workdir.tmp --psel data --links --include $SRC_ID -vv1 -F-.svn/ || exit 1

. ./copy-files.sh

wit copy workdir.tmp -T0 --DEST new-image/%X  -ovv --links \
	--id "$DEST_ID" --ticket-id=RMCR --tmd-id=RMCR --boot-id=RMCE --security-fix --name "$DEST_NAME" --$IMAGE_TYPE --split

