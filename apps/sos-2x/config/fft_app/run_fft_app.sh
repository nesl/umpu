#!/bin/bash

## Script for running the blank kernel
java avrora/Main \
    -simulation=sensor-network -sections=.data,.text,.sos_bls,.sfijmptbl \
    -random-seed=151079 -random-start=[0,100000000] \
    -topology=avrora_input_topology -nodecount=1 -update-node-id=true \
    fft_app.od

# Normal Mode Profiling
#java avrora/Main \
#    -simulation=sensor-network -sections=.data,.text,.sos_bls \
#    -monitors=SOSJava.SOSPacketMonitor,serial,sleep,trip-time \
#    -pairs=0x1032:0x1138,0x113a:0x11ae,0xe18:0xe5c\
#    -ports=1:0:8314 \
#    -show-tree-packets=true \
#    -random-seed=151079 -random-start=[0,100000000] \
#    -report-seconds -seconds-precision=2 -seconds=1800.0 \
#    -topology=avrora_input_topology -nodecount=4 -update-node-id=true \
#    blank.od

# SFI Mode Profiling
#java avrora/Main \
#    -simulation=sensor-network -sections=.data,.text,.sos_bls,.sfijmptbl \
#    -monitors=SOSJava.SOSPacketMonitor,serial,sleep,trip-time,SOSJava.SOSCrashMonitor \
#    -sfi-exception-addr=44246\
#    -memmap-addr=3168\
#    -pairs=0x1312:0x1464,0x14be:0x15e4,0x15e6:0x16ee,0xaf22:0xaf88,0xafc8:0xb02e,0xb030:0xb05e,\
#0xb060:0xb094,0xb096:0xb0ca\
#    -ports=1:0:8314 \
#    -show-tree-packets=true \
#    -random-seed=151079 -random-start=[0,100000000] \
#    -report-seconds -seconds-precision=2 -seconds=1800.0 \
#    -topology=avrora_input_topology -nodecount=4 -update-node-id=true \
#    blank.od

# Buff Writer
#java avrora/Main \
#    -simulation=sensor-network -sections=.data,.text,.sos_bls,.sfijmptbl \
#    -monitors=SOSJava.SOSPacketMonitor,SOSJava.SOSCrashMonitor,sleep,serial\
#    -ports=0:0:8314 \
#    -show-packets=true\
#    -show-tree-packets=true \
#    -seconds=300\
#    -random-seed=151079 -random-start=[0,100000000] \
#    -topology=avrora_input_topology -nodecount=1 -update-node-id=true \
#    blank.od