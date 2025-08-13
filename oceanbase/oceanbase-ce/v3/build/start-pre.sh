#!/bin/bash
/root/convert-sparse-files.sh /root/demo/store /tmp/store 
/root/handle-clog.sh > /root/empty_clog
cp -r /root/demo/etc /root/share 
cp -r /root/.obd/cluster /root/share
cp -r /root/empty_clog /root/share 
cp -r /root/demo/store /root/share 
cd /root/share && mksquashfs store store.img
cd /root/share && rm -rf etc/obshell && mksquashfs etc etc.img
