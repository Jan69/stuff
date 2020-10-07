#enable Scroll Lock keyboard LED toggle?
allowLED="yes" #empty/commented=disabled
enableLED(){  xset  led named "Scroll Lock";}
disableLED(){ xset -led named "Scroll Lock";}
flashLED(){
 for i in $(seq 3);do #10 flashes
  enableLED
  #each time led on for x seconds
  sleep 0.5
  disableLED
  #need to see it's off too
  sleep 0.5
  echo "cycle $i"
 done
}

file="$1"
if [ ! "$file" ];then
 echo "no file to monitor given"
 exit 1
fi

for i in "$@";do
 echo "monitoring $i" >&2
 a="$(stat -c %Y "$file")" #base modification time (epoch)
 while true;do
  b="$(stat -c %Y "$file")" #get new "last modified" time
  if [ "$a" = "$b" -a "$b" != "" ];then #time unchanged & != null
   true #no-op, could also negate the tests and skip it
  else
   a="$b" #update the base modification time
   echo "FILE $file MODIFIED (on $(date +"%Y-%m-%d %T"))"
   flashLED
  fi
  sleep 2
 done
done
