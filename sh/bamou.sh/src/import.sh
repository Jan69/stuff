import(){
if [ -f ./"$1" ];then
 . ./"$1";
elif [ -f ./"$1.sh" ];then
 . ./"$1.sh";
else echo "ERR";fi
}
