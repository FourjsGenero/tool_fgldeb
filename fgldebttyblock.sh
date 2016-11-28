#!/bin/sh
echo "tty:`tty`"
#change standard interrupt to something
stty intr ÿ
sleep 10000000000
