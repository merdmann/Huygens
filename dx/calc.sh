#!/bin/sh -x
if [ -z "$2" ] ; then
   f=0.0
else
   f="$2"
fi

rm -rf $1
mkdir -p $1

for i in 000 005 010 015 020 025 030 035 040 045 050 055 060 065 070 075 080 085 086 087 088 089 095\
 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 115 180 185 186 187 188 189 195 200 ; do
   echo -n $i ....
   ./di.sh --config=$1 --phase=$f --T=$i --image=$1/${i}_$1.jpg
   echo
done
cd $1
mogrify -format gif *.jpg
gifsicle --colors=256 --delay=50 --loopcount=0 *.gif > ../$1.gif

