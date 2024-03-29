#!/bin/sh

exec 3>&2 2>&1 1>&3 3>&- #stdout to stderr, and vice versa

echo "arrow keys to change selection"
#TODO: allow numeric selections
#echo "warning, holding/spamming keys will lag out"
echo
unset -v c;
#null=/dev/null

submenu=0

if [ -n "$1" ];then
#require starting newline, makes it nicer as all the text would have same indent
#no newline at the end though
 text="
QUIT
$1
";shift
 for i in "$@";do text="$text$i
";done
else
 text='
QUIT
first
hello
ahoy
yeehaw
something
all hail jan6
sailing
888
NEIN
yollo
and
whatnot
more
'
fi
#auto-numbering, assuming you won't need more than 99 items
text="$(echo "${text}"|nl -v 0 -b t -s ") "|sed -e "s/^[[:blank:]]*\([^[:blank:]].\+\)/(\1/" -e "s/^(\([0-9][^0-9]\)/(0\1/" )"

r1b(){
 #magic function to read one byte, trying to be posix
 #TODO: detect shell and use builtin functions of bash, zsh etc when available
 #probably a lot faster that way
 if [ -t 0 ];then
  stty_bak="$(stty -g)";
  stty -icanon min 1 time 0 -echo;
 fi;
 c="$(dd bs=1 count=1 2> /dev/null; echo .)";c="${c%.}";
 if [ -t 0 ];then
  stty "${stty_bak}";
 fi;
 if [ -z "${c}" ];then exit 1;fi
 printf '%s\n' "${c}" ;
# unset -v c;
};

b(){
 #this function detects arrow key directions
 key="$(r1b)"
 case "$key" in
  (""|[[:blank:]]|[nN]) echo "select  ↵";;
  ('')  if [ "$(r1b)" = '[' ];then
#         it's a CSI escape sequence

#         read one direction key,
#         ESC[A for example,
#         reading only third char,
#         then translating to direction
          case "$(r1b)" in
           ("A") d="up   	↑";;
           ("B") d="down 	↓";;
           ("C") d="right	→";;
           ("D") d="left 	←";;
          esac;
          echo "${d}";
         else echo "ESC";
         fi;
  ;;
  ([hjklHJKLwasdWASD])
          case "$key" in
           ([wWkK]) d="up   	↑";;
           ([sSjJ]) d="down 	↓";;
           ([dDlL]) d="right	→";;
           ([aAhH]) d="left 	←";;
          esac;
          echo "${d}";;
  ([1-9]) echo "direct $((key+1))";;
  ([qQ0]) echo "quit ×";;
  (*) echo "OTHER";;
 esac
}

quit(){ printf "\033[999D";exit 0;}

choose(){ n="$1"
 printf "\033[8A\033[K%s\033[8B" "$(echo "${text}"|tail -n +"${n}"|head -n 1)" #>&2
 m="$((n-1))" #because starting with 0
 case "${m}" in
  (0) quit;;
  (*) echo "${text}"|tail -n +"${n}"|head -n 1|cut -d \  -f 2- >&2; quit;;
 esac
}

#wrap overflow
wrap(){ n="$1"
 if [ "${n}" -gt "$(echo "${text}"|wc -l)" ];then n="1";
 elif [ "${n}" -lt "1" ];then n="$(echo "${text}"|wc -l)";fi
 printf "%s\n" "${n}"
}

printfscreen() {
 printf \
"$(printf "%7s" ''|sed 's/ /\\033[999D\\033[K\\033[1A/g')\033[999D\033[K"\
"%s%$((ll+2))s%s\n"\
"%s\033[%s %-${ll}s \033[0m%s\n"\
"%s\033[%s %-${ll}s \033[0m%s\n"\
"%s\033[%s %-${ll}s \033[0m%s\n"\
"%s\033[%s %-${ll}s \033[0m%s\n"\
"%s\033[%s %-${ll}s \033[0m%s\n"\
"%s%-$((ll+2))s%s\n"\
 "${frame_top_left}" "$(printf "%$((ll+2))s"|sed "s/ /${frame_top_mid}/g")" "${frame_top_right}" \
 "${frame_mid_left}" "$esc1" "$(if [ "$(wrap $((n-1)))" = "$maxline" ];then  n=$((maxline-1)); else n=$((n-2)); fi;n="$(wrap "${n}")";echo "${text}"|tail -n +"${n}"|head -n 1)" "${frame_mid_right}" \
 "${frame_mid_left}" "$esc2" "$(n="$(wrap "$((n-1))")";echo "${text}"|tail -n +"${n}"|head -n 1)" "${frame_mid_right}" \
 "${frame_mid_left}" "$esc3" "$(echo "${text}"|tail -n +"${n}"|head -n 1)" "${frame_mid_right}" \
 "${frame_mid_left}" "$esc2" "$(n="$(wrap "$((n+1))")";echo "${text}"|tail -n +"${n}"|head -n 1)" "${frame_mid_right}" \
 "${frame_mid_left}" "$esc1" "$(if [ "$(wrap $((n+1)))" = "$minline" ];then n=$((minline+1));else n=$((n+2));fi;n="$(wrap "${n}")";echo "${text}"|tail -n +"${n}"|head -n 1)" "${frame_mid_right}" \
 "${frame_btm_left}" "$(printf "%$((ll+2))s"|sed "s/ /${frame_btm_mid}/g")" "${frame_btm_right}" \

}

#longest line
ll="$(echo "${text}"|awk 'length > l {l=length;line=$0} END {print line}'|wc -m)"
#text has extra lines to make it look proper, now we remove them
text="$(echo "${text}"|tail -n +2|head -n -1)"
#get max line nr
maxline="$(echo "${text}"|wc -l)"
minline="1"

frame="┌
─
┐
│
│
└
─
┘"

: '
#16-color, non-bold
esc1="90m"
esc2="37;2m"
esc3="97;1m"
# '
#256-color
#: '
esc1="38;5;238m"
esc2="38;5;247m"
esc3="37;1m"
# '
#esc_b_2="31m"
#esc_b_2="$esc1"

frame_top_left="$(echo "$frame"|tail -n +1|head -n 1)"
frame_top_mid="$(echo "$frame"|tail -n +2|head -n 1)"
frame_top_right="$(echo "$frame"|tail -n +3|head -n 1)"
frame_mid_left="$(echo "$frame"|tail -n +4|head -n 1)"
frame_mid_right="$(echo "$frame"|tail -n +5|head -n 1)"
frame_btm_left="$(echo "$frame"|tail -n +6|head -n 1)"
frame_btm_mid="$(echo "$frame"|tail -n +7|head -n 1)"
frame_btm_right="$(echo "$frame"|tail -n +8|head -n 1)"

#framediv_left="$(echo "${framediv}"|tail -n +1|head -n 1)"
#framediv_mid="$(echo "${framediv}"|tail -n +2|head -n 1)"
#framediv_right="$(echo "${framediv}"|tail -n +3|head -n 1)"


n=1 #line nr
#initial screen print
#printf " ";echo "${text}"|tail -n +"${n}"|head -n 1|tr -d "\n"
printf "%7s" ""|tr " " "\n"
printfscreen

while true;do
 #i=$((i + 1));
 ba="$(b|awk '{print $2}')"
 case "$ba" in
  ("↓") n=$((n + 1)) ;;
  ("↑") n=$((n - 1)) ;;
  ("←") : ;;
  ("→") : ;;
  ("↵") choose "$n";;
  ([0-9]*) choose "$ba";;
  ("×") choose 1;; #quit
  ( * ) : ;;
 esac;
 n="$(wrap "${n}")";
 printfscreen
# echo "$i";
done;

unset -v i;
unset -v c;
