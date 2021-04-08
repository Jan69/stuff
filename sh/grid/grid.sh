#!/bin/sh
if [ -z "${COLUMNS}" ] || [ -z "${LINES}" ];then
 eval "$(stty size|tr -s "[:blank:]"|sed "s/\([0-9]\+\) \([0-9]\+\)/LINES=\1 COLUMNS=\2/")"
fi
LINES="${LINES:-25}"
COLUMNS="${COLUMNS:-80}"

border_width=1


border_width_x="${border_width}"
border_width_y="${border_width}"

border(){
 width="$((COLUMNS-2))"
 height="${LINES}"
 printf "%s%${width}s%s\n" "${1:-@}" "" "${3:-@}"|sed "s/ /${2:--}/g"
 for _ in $(seq 1 "$((height-3))");do
  printf "%s%$((COLUMNS-2))s%s\n" "${4:-|}" "" "${5:-|}"
 done
 printf "%s%${width}s%s\n" "${6:-@}" "" "${8:-@}"|sed "s/ /${7:--}/g"
}
#ascii, also fallback
#border "@" "-" "@" "|" "|" "@" "-" "@"
#fancy (single-character sections only for now)
border "▗" "▀" "▖" "█" "█" "▝" "▄" "▘"

draw(){
 x="$1";y="$2";text="$3"
 printf "\033[%d;%dH%s" "$((y+border_width_y))" "$((x+border_width_x))" "${text}"
 #move cursor back down after done with drawing
 printf "\033[%d;%dH" "${LINES}" "0"
}

draw 2 -1 "${LINES}x${COLUMNS}"

draw 2 1 "hello"
draw 10 2 "world"
