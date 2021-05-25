#!/bin/bash

DB_PASS=$(echo "$(hostname)$(hostname -I)$(date +%s)$(echo $RANDOM)" | sha1sum | cut -c1-12)

echo "DB_PASS is: $DB_PASS"
