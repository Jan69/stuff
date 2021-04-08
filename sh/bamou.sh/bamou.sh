#!/bin/sh
. src/import.sh

import src/constants
import src/functions
import modules/output/bare
import modules/input/ping

echo "
listing of keys:"
getkey LIST|while read i;do p "$i";done
echo "
listing of key values:"
getkey list|while read i;do printf "%s " "$i:";getkey "$i";done
echo "
second value of \"test\":"
getkey TeSt|cut -f 2
echo "
enumerating values of \"test\":"
for i in $(getkey test);do n="$((n+1))";echo "$n: $i";done
echo "
pinging google"
ping google.com
