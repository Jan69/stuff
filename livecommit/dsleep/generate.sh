#!/usr/bin/env bash
CC="${CC:-"diet"}"

#compile statically, should be able to copy to any linux
static="-static"

case "$CC" in #special handling
 ("diet") special="gcc";; #just annoying
 ("musl") CC="musl-gcc";; #just convenient
 ("tcc") static="";echo "TCC cannot compile statically!" >&2;; #tcc segmentation faults at static compilation
esac

#set values here manually, too lazy to parse arguments, lol
for s in "$static" "";do
 for v in "speed" "size";do

  /usr/bin/time >&2 -f %E sh -c '{ #timings 4 debug
  v="'"$v"'";dir="'"$dir"'";CC="'"$CC"'";s="'"$s"'";special="'"$special"'";static="$s";s="$(echo "${s:-"-shared"}"|tail -c +2)" #timings 4 debug

  dir="out/$s/$CC/${v}_optimized"
  mkdir -p "$dir"
  #printf "\033[31m%s\033[0m\n" "$dir"

  for i in 0.7;do #$(LC_ALL=C seq -w 0.1 0.1 0.9);do
   out="$dir/sleep_$i"
   #echo "$out"
   if [ "$v" = "size" ];then o="-Os";else o="-O3";fi
   echo "${CC:-cc}" $special "$o" $static -DSECONDS="$i" -o "$out" nanosleep.c&&
   "${CC:-cc}" $special "$o" $static -DSECONDS="$i" -o "$out" nanosleep.c&&
   strip -s "$out"
  done

  printf "%s" "$CC -${static:-"-shared"} with ${v}_optimized took " >&2;}' #timings 4 debug

 done
done
