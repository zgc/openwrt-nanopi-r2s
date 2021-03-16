#!/bin/sh
DATE=$(date +%Y-%m-%d-%H:%M:%S)
tries=0
LOG=/tmp/check_smartdns_connect.log
ALIYUN=alidns.com
while [ $tries -lt 5 ]; do
  NSLOOKUP=$(nslookup $ALIYUN | grep -v grep | grep 'Address ' | wc -l)
  if [ ${NSLOOKUP} -ne 0 ]; then
    echo $DATE check smartdns connect: OK >>$LOG
    exit 0
  else
    let tries++
    echo $DATE tries: $tries, smartdns restart >>$LOG
    /etc/init.d/smartdns restart
    sleep 10
  fi
done
