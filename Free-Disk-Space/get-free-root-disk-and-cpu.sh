#!/bin/sh
CPU_USAGE=$((100-$(vmstat 1 2|tail -1|awk '{print $15}')))
echo $CPU_USAGE 
df -h /dev/root
