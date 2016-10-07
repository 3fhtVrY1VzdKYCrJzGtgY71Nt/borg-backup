#!/bin/sh

source /etc/borg.conf

echo "



##### starting backup at $DATE (real date is $(timeout 1 curl -G --data-urlencode \"format=%D-%T\n\" http://www.timeapi.org/cest/1+hours+before+now?)) #####"     >> $LOG 2>&1

borg create                           \
    $REPOSITORY::'{hostname}-{now}'    \
    --exclude-from /etc/borg.exclusion		\
    --compression lzma,9                        \
    --verbose --stats                           \
    $DATA                                       \
    >> $LOG 2>&1

if [[ $? -eq 2 ]]
	then echo "aborted, already exists. exiting."  >> $LOG
	exit 127
fi

echo "##### ending backup at $DATE  #####
... pruning
 "     >> $LOG 2>&1

borg prune --debug --list --prefix '{hostname}-' --keep-within=1H --keep-hourly=1 --keep-daily=2 --keep-weekly=1 --keep-monthly=1 $REPOSITORY >> $LOG 2>&1|| echo "pruning failed">> $LOG


echo "

##### done.               #####

"     >> $LOG 2>&1

echo "##### starting 1st transfer at $DATE #####"     >> $LOG 2>&1
drive -c /home/jlehulud/.gdrive sync upload $REPOSITORY 0B3ZbmRr1RRkHVGlObFdHTzN2QVU >> $LOG 2>&1

echo "

##### done. starting next transfer    $DATE #####

"     >> $LOG 2>&1

drive -c /home/jlehulud/.gdrive-secondary sync upload $REPOSITORY 0B8HiID_B112OSzdNZ2tOeHRRSDQ >> $LOG 2>&1

echo "##### done 2nd transfer at $DATE (real date is $(timeout 1 curl -G --data-urlencode \"format=%D-%T\n\" http://www.timeapi.org/cest/1+hours+before+now?)) #####"     >> $LOG 2>&1

