#!/bin/sh
DATE=`date +%Y-%m-%d-%H:%M:%S`
tries=0
LOG=/tmp/check_wan_connect.log
PPPOE=`/sbin/ifconfig | grep -v grep | grep 'pppoe-wan' | wc -l`
ALIYUN=223.5.5.5
if [ ${PPPOE} -ne 0 ]; then
    while [ $tries -lt 5 ]; do
        PING=`ping -c1 $ALIYUN | grep -v grep | grep '64 bytes' | wc -l`
        if [ ${PING} -ne 0 ]; then
            echo $DATE check ppp connect: OK >> $LOG
            exit 0
        else
            let tries++
            echo $DATE tries: $tries, ppp restart >> $LOG
            ifdown wan | ifup wan
            sleep 10
        fi
    done
else
    while [ $tries -lt 5 ]; do
        eth1=`/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
        if [ -n ${eth1} ]; then
            GATEWAY=`echo $eth1 | awk 'BEGIN{FS=OFS="."}{$NF=1;print}'`
            PING=`ping -c1 $GATEWAY | grep -v grep | grep '64 bytes' | wc -l`
            if [ ${PING} -ne 0 ]; then
                echo $DATE check wan connect: OK >> $LOG
                exit 0
            else
                let tries++
                echo $DATE tries: $tries, wan restart >> $LOG
                ifdown wan | ifup wan
                sleep 10
            fi
        else
            echo $DATE wan not connect >> $LOG
            exit 0
        fi
    done
fi