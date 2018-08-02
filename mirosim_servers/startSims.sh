#!/usr/bin/env bash
IPADDR=$(ifconfig eno1 | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')

if [ $IPADDR == '192.168.1.129' ]
then
        echo "SERVER 1"
        SRV=1
elif [ $IPADDR == '192.168.1.219' ]
then
        echo "SERVER 2"
        SRV=2
elif [ $IPADDR == '192.168.1.186' ]
then
        echo "SERVER 3"
        SRV=3
else
        echo "SHIT"
        SRV=a
fi

for i in `seq 0 2`;
do
    cmd="docker start mirosim"$i"_srv"$SRV""
    echo $cmd
    eval $cmd
done
