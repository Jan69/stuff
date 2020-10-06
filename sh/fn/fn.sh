#!/bin/sh
# this is a script to help manage shell functions
# it rudimentally parses given file for apparrent function declarations
# and lists the names of found functions

ret(){ return "$1";} ;: "return a status code
(regular "return" requires to be inside a function or such statement)"
eecho() { echo >&2 "$@";} #error echo (echo to stderr)
eprintf() { printf >&2 "$@";} #error printf (printf to stderr)
randbit() {
 a="$(LC_ALL=C grep -ao "[[:digit:]]" /dev/urandom|head -n 3|shuf|head -n 1)"
 if test "$a" -ge 5;then echo 1;return 1; else echo 0;return 0;fi
}

print_usage() { printf "%s" "\
usage: $(basename $0) <filename>
" >&2;}
print_help() {
 print_usage
 echo "prints all functions in filename "\
     "(or itself, when no file provided)" >&2;}

test_arg_file() {
 if test -n "$1";then
  eecho "argument given"
 else eecho "no argument";return 2
 fi
 if [ -e "$1" -o "0" -eq "$(which "$1" >/dev/null;echo $?)" ];then
  eecho "file exists";return 0
 else eecho "invalid filename";return 1
 fi
}

run_normal(){
 eecho "normality"
} 
run_invalid(){
 eecho "invalidity"
}
run_self(){
 eecho "selfity"
}
run_unknown(){
 eecho "FATALITY! $@"
 if [ "$(randbit)" != 0 ];then
  a="HIM"
 else
  a="HER"
 fi
 return $(echo "FINISH $a!"|tee /dev/stderr|wc -c)
}

test_arg_file "$1"
ret 99
case $? in
(0) run_normal ;;
(1) run_invalid;;
(2) run_self   ;;
(*) run_unknown;;
esac

help=""
if test "$help";then print_help;fi
