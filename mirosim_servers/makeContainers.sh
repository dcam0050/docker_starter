#!/usr/bin/env bash
IPADDR=$(ifconfig eno1 | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
NUM_SIMS=2
NUM_SRVS=3

BASE_NGINX=9036
BASE_BLOCKLY=1036
BASE_GZWEB=8080
BASE_BACKEND=9000

for i in `seq 0 $NUM_SIMS`;
do
    ng=$(($BASE_NGINX+$i))
    bk=$(($BASE_BLOCKLY+$i))
    gz=$(($BASE_GZWEB+$i))
    bke=$(($BASE_BACKEND+$i))

    for j in `seq 1 $NUM_SRVS`;
    do  
        cmd="./mirosim_image.sh dcamilleri13/all_connected:dev_mode mirosim"$i"_srv"$j" $ng $bk $gz $bke"
        echo $cmd
        eval $cmd
    done
done
