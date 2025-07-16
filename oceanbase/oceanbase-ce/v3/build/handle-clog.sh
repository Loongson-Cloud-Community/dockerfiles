#!/bin/bash

find "/root/demo/store/clog/log_pool" -type f | while read -r file; do
    actual_size=$(du -sh "$file" | awk '{print $1}')
    if [[ "$actual_size" == 0* ]]; then
        echo "$file"
        rm -rf $file
    fi
done
