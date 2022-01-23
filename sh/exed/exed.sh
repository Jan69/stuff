#!/bin/sh
exec 3<&0
r1b(){
 unset -v c;
 if [ -t 0 ];then
  stty_bak=$(stty -g);
  stty -icanon min 1 time 0 -echo;
 fi;
 c="$(dd bs=1 count=1 2>/dev/null; echo .)";c="${c%.}";
 if [ -t 0 ];then
  stty "${stty_bak}";
 fi;
 printf '%s\n' "${c}" ;
# unset -v c;
};

file="${1:-list.txt}"

grep -v '^[[:blank:]]*#' "${file}"|
while read -r i;do
 ix="$(echo "${i}"|sed 's/\"/\\"/g')"
 printf "\n%s\n\n%s\n\n%s\n\n" \
      "-------" \
      "${i}"       \
      "(a)ccept, (d)elete, (c)omment, (i)gnore?"
 #read -r c <&3
 c="$(r1b <&3)"
 case "${c}" in
  (i)echo "skipping!";continue;;
  (a|c)
  	 case "${c}" in
  	  (a)
       echo "accepting ${i}"
       eval "${i}";;
      (c)
       echo "commenting ${i}";;
     esac
     t="$(mktemp)"
     cp "${file}" "${t}" &&
     awk "{
        if(\$0 == \"${ix}\")"'{
         print "#"$0
        }else{
         print $0
        };}' >"${t}" <"${file}" &&
     (cat "${t}" >"${file}"||echo "modified file in ${t}")&&
     rm "$t"
  ;;
  (d)
     echo "really delete? (y/n)"
     if [ "$(r1b <&3)" != "y" ];then
      echo "skipping!"
      continue
     fi
     echo "DELETING ${i}"
     t="$(mktemp)"
     cp -p "${file}" "${t}" &&
     awk "{
        if(\$0 != \"${ix}\")"'{
         print $0
        };}' >"${t}" <"${file}" &&
     (cat "${t}" >"${file}"||echo "modified file in ${t}")&&
     rm "$t"
  ;;
 (*)echo "skipping!";continue;;
 esac
 #echo "${c} ${i}"
done
