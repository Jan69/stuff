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
'
text2='
(2.1) hello again
(2.2) ahoy there
(2.3) test 30
'

current_text="text1"
#evil eval is the only way to not hardcode variables and stuff
text="$(eval "echo \"\$$current_text\"")"
selected="false"
#text has extra lines to make it look proper, now we remove them
#text="$(echo "$text"|tail -n +2|head -n -1)"
text="$(echo "$text"|tail -n +2)"
n=1 #line nr
printf " ";echo "$text"|tail -n +"$n"|head -n 1|tr -d "\n"
while true;do
 i=$((i + 1));
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
  printf "\033[2K\033[999D %s " "$(echo "$text"|tail -n +"$n"|head -n 1)";
# echo "$i";
 else
  printf "\033[99D"
  selected="false"
  if [ "$current_text" == "text1" ];then
  #temporarily hardcoding variables, could be extended to unlimited texts with eval-ing
   printf "\033[2A"
   echo "selected $current_text nr. $n"
   export current_text="text2"
   printf "\033[2B"
  else
   printf "\033[1A"
   echo "selected $current_text nr. $n"
   export current_text="text1"
   printf "\033[1B"
  fi
  text="$(eval "echo \"\$$current_text\"")"
  text="$(echo "$text"|tail -n +2)"
  n=1
  printf "\033[2K\033[999D %s " "$(echo "$text"|tail -n +"$n"|head -n 1)";
 fi
done;

unset -v i;
unset -v c;
