#get a key, or list all keys in settings file
getkey(){
 key_name="$(echo "$1"|tr [:lower:] [:upper:])"
 if [ -z "$key_name" ];then echo "must use a setting name,";echo " or \"LIST\" to list all keys";return 1;fi
 config="$(grep -o "^[^[:blank:]#]\+[^=]\+=.\+" settings.conf|sort)"
 ret="$(
 echo "$config"|cut -d = -f 1|while read key;do
  if [ "$key_name" != "$key" ]&&[ "$key_name" != "LIST" ];then continue;fi
  #printf "%s" "$key"
  if [ "$key_name" = "LIST" ];then echo "$key";continue;fi
  echo "$config"|grep "^[[:blank:]]*$key"|cut -d = -f 2|tr \` "\n"|tr "[:upper:]" "[:lower:]" |
  while read value;do
   printf "\t%s" "$value"
   #eval "_$key=\"_$key$t$value\""
  done|cut -f 2-
  echo
 done
 )"
 if [ -z "$ret" ];then echo "invalid key \"$key_name\"";return 1;else echo "$ret";fi
}
