#!/bin/sh
# this is a script to help manage shell functions
# it rudimentally parses given file for apparrent function declarations
# and lists the names of found functions
echo "broke rn";exit 1
#comments with JUMP are jump points because of a plugin in my editor
#(geany "addons" addon)
: "
you can cheat multiline comments
by using "true" aka ":" and just giving the comment as argument(s)
the arguments are ignored, so it's a nearly no-op comment
"
if [ "$1" = "_" ];then { (shift) 2>/dev/null&&echo "shifted!";}||true;fi

#JUMP variables, mostly to ease debug and testing TODO: split off and source

#booleans, default to empty/commented for release, set a value to debug
variables()true;

#help='  ;_;  '
debug=' "_"  '
#runmode=9 #set this to override runmode 0=normal 1=invalid 2=self *=???
fileoverride="README"


#reusable utility functions

ret(){ return "$1";} ;: 'return a status code
(regular "return" requires to be inside a function or such statement)'

eecho() { echo >&2 "$@";} #error echo (echo to stderr)
eprintf() { printf >&2 "$@";}

decho() { if [ "$1" ];then shift;eecho "$@";fi;} #if variable, then echo
dprintf() { if [ "$1" ];then shift;eprintf "$@";fi;}

ddecho() { decho "$debug" "<DEBUG> $@";} #echo if debug, else nothing
ddprintf1() { #printf from the start of line
 a="%s $1";b="<DEBUG> $2";
 shift;shift;
 dprintf "$debug" "$a" "$b" "$@"
}
#don't want <DEBUG> in the middle of the line, so two variants of printf
ddprintf() { dprintf "$debug" "$@";}

CSI="$(printf "\033[")"
reset="${CSI}0m"
bold="${CSI}1m"
bold() {
 case "$1" in
  (*echo)
   a="$1"
   shift
   "$a" "$bold$@$reset";;
  (*)
   eecho "bold fail!";
 esac
}


randbit() { #returns and outputs either 1 or 0
 a="$(
   LC_ALL=C grep -ao "[[:digit:]]" /dev/urandom|
   head -n 3|shuf|head -n 1
 )"
 if test "$a" -ge 5;then
  printf "%d" 1;
  return 1;
 else
  printf "%d" 0;
  return 0;
 fi
}



#JUMP main functions

print_usage() { eprintf "%s" "\
usage: $(basename $0) <filename>
" >&2;}
print_help() {
 print_usage
 eecho "prints all functions in filename "\
     "(or itself, when no file provided)" >&2;}

test_arg_file() {
 for i in "$@";do
  if test -n "$i";then
   if [ -e "$i" ] || [ "0" -eq "$(which "$i" >/dev/null;echo $?)" ];then
    ddecho "file exists";return 0
   else ddecho "invalid filename";return 1
   fi
  else ddecho "no argument";return 2
  fi
 done
}

run_normal(){
 ddecho "run|$@|"
 if [ "$1" = "" ];then shift;else ddecho "normality";fi
 grep -o "[[:alpha:]][^ ]*()[[:space:]]" "$(which $@)"
} 
run_invalid(){
 ddecho "invalidity"
}
run_self(){
 ddecho "selfity";run_normal "" "$@"
}
run_unknown(){
 ddprintf1 "\033[1m%s" "FATALITY! $@ HP left..."
 if [ "$(randbit)" != 0 ];then
  a="HIM"
 else
  a="HER"
 fi
 ddprintf "%s\033[0m\n" "FINISH $a!!!"
 return $(echo "FINISH $a!"|wc -c) #always returns 12
}

test_arg_file "$@"
r=$?
if [ -n "$fileoverride" ] && [ "$1" != "$fileoverride" ];then "$0" "_" "$fileoverride";fi
ddecho "|$@|"

if [ "$runmode" ];then ret $runmode;else ret $r;fi #overwrite test result when debug

case $? in
(0) run_normal "$@";;
(1) run_invalid;;
(2) run_self   "$0";;
(*) run_unknown $?;;
esac

if test "$help";then print_help;fi
