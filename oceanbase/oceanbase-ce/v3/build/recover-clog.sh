#!/bin/bash

for file in `cat /root/empty_clog`; do 
    truncate -s 64M "$file"
done
