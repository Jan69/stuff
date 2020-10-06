#!/bin/sh
# this is a script to help manage shell functions
# it rudimentally parses given file for apparrent function declarations
# and lists the names of found functions

#comments with JUMP are jump points because of a plugin in my editor (geany "addons" addon)
: "
you can cheat multiline comments
by using "true" aka ":" and just giving the comment as argument(s)
the arguments are ignored, so it's a nearly no-op comment
"

#JUMP variables, mostly to ease debug and testing TODO: split off and source

#booleans, default to empty/commented for release, set a value to debug
variables() true;
#help='  ;_;  '
debug=' "_"  '
#runmode=2 #set this to override runmode 0=normal 1=invalid 2=self *=???


#reusable utility functions

ret(){ return "$1";} ;: 'return a status code
(regular "return" requires to be inside a function or such statement)'

eecho() { echo >&2 "$@";} #error echo (echo to stderr)
eprintf() { printf >&2 "$@";}

decho() { if [ "$1" ];then shift;eecho "$@";fi;} #if variable, then echo
dprintf() { if [ "$1" ];then shift;eprintf "$@";fi;}

ddecho() { decho "$debug" "$@";} #echo if debug, else nothing
ddprintf() { dprintf "$debug" "$@";}

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


#main functions

print_usage() { printf "%s" "\
usage: $(basename $0) <filename>
" >&2;}
print_help() {
 print_usage
 echo "prints all functions in filename "\
     "(or itself, when no file provided)" >&2;}

test_arg_file() {
 if test -n "$1";then
  ddecho "argument given"
 else ddecho "no argument";return 2
 fi
 if [ -e "$1" -o "0" -eq "$(which "$1" >/dev/null;echo $?)" ];then
  ddecho "file exists";return 0
 else ddecho "invalid filename";return 1
 fi
}

run_normal(){
 ddecho "normality"
} 
run_invalid(){
 ddecho "invalidity"
}
run_self(){
 ddecho "selfity"
}
run_unknown(){
 ddprintf "%s" "FATALITY! $@"
 if [ "$(randbit)" != 0 ];then
  a="HIM"
 else
  a="HER"
 fi
 ddecho "finish $a"
 return $(echo "FINISH $a!"|wc -c) #always returns 12
}

test_arg_file "$1"

if [ "$runmode" ];then ret $runmode;fi #overwrite test result when debug

case $? in
(0) run_normal ;;
(1) run_invalid;;
(2) run_self   ;;
(*) run_unknown;;
esac

if test "$help";then print_help;fi
