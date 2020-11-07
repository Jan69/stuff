#!/bin/sh
#script to get user selection, currently options are hardcoded
echo "arrow keys to change selection"
echo ""
echo ""
#TODO: allow numeric selections
unset -v c;

r1b(){
 #magic function to read one byte, trying to be posix
 #TODO: detect shell and use builtin functions of bash, zsh etc when available
 if [ -t 0 ];then
  stty_bak=$(stty -g);
  stty -icanon min 1 time 0 -echo;
 fi;
 c=$(dd bs=1 count=1 2> /dev/null; echo .);c=${c%.};
 if [ -t 0 ];then
  stty "$stty_bak";
 fi;
 printf '%s\n' "$c" ;
# unset -v c;
};

b(){
 #this function detects arrow key directions
 a="$(r1b)"
 case "$a" in
  ("") echo "INPUT NULL";;
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
          echo "$d";
         else echo "ESC";
         fi;
  ;;
  (*) echo "SOMETHING OTHER";;
 esac
}


text1='
(1.1) hello
(1.2) ahoy
(1.3) test 3
(1.4) yeehaw
(1.5) trolololo
'
text2='
(2.1) hello again
(2.2) ahoy there
(2.3) test 30
(3.4) maan
(3.5) huehue
'

line_count=5
current_text="text1"
#evil eval is the only way to not hardcode variables and stuff
#at the start, it goes: \$$current_text replaced by shell -> $text1 evaluated by eval -> into variable
text="$(eval "echo \"\$$current_text\"")"
selected="false"
#text has extra lines to make it look proper, now we remove them
#text="$(echo "$text"|tail -n +2|head -n -1)"
text="$(echo "$text"|tail -n +2)"
text_buffer="$({ echo "$text";echo "$text";echo "$text";}|tr -s "\n")"
n=1 #line nr
echo "selected \$current_text nr. \$n"
echo "selected \$current_text nr. \$n"
echo
echo "$text_buffer"|head -n +"$(($n+1+$line_count))"|tail -n "$line_count"|sed 's/$/\x1b[0K/'
printf "\033[1A"
while true;do
 i=$((i + 1));
 line="$(echo "$text_buffer"|head -n +"$(($n+1+$line_count))"|tail -n "$line_count"|sed -e "s/$/\x1b[0K/" -e "s/^[[:blank:]]*/  /" \
                                                                  -e "$(( ($line_count+1) / 2))s/^  /\x1b[31m> /" -e "$(( ($line_count+1) / 2))s/$/\x1b[0m/")"
 o="$(b|awk '{print $2}')"
 case "$o" in
  ("↓") x="↓";n=$((n + 1)) ;;
  ("↑") x="↑";n=$((n - 1)) ;;
  ("←") x="←"; ;;
  ("→") x="→"; ;;
  ("NULL") x="~"; selected="true";;
 esac;
 if [ "$selected" == "false" ];then
  if [ "$n" -gt "$(echo "$text"|wc -l)" ];then n="1";fi
  if [ "$n" -lt "1" ];then n="$(echo "$text"|wc -l)";fi
  printf "\033[2K\033[$(($line_count - 1))A\033[999D%s" "$line"
 else
  printf "\033[99D"
  selected="false"
  if [ "$current_text" == "text1" ];then
  #temporarily hardcoding variables, could be extended to unlimited texts with eval-ing
   printf "\033[$(($line_count+2))A\033[0K"
   echo "selected $current_text nr. $n"
   printf "\033[$(($line_count+1))B"
   export current_text="text2"
  else
   printf "\033[$(($line_count+1))A\033[0K"
   echo "selected $current_text nr. $n"
   printf "\033[$(($line_count+0))B"
   export current_text="text1"
  fi
  text="$(eval "echo \"\$$current_text\"")"
  text="$(echo "$text"|tail -n +2)"
  text_buffer="$({ echo "$text";echo "$text";echo "$text";}|tr -s "\n")"
  n=1
  printf "\033[2K\033[$(($line_count - 1))A\033[999D%s" "$line"
 fi
done;

unset -v i;
unset -v c;
