#                                                                         
# Copyright (C) 2010 Michael Erdmann                                      
#                                                                           
# PSIM is copyrighted by the persons and institutions enumerated in the   
# AUTHORS file. This file is located in the root directory of the          
# PSIM distribution.                                                      
#                                                                          
# PSIM is free software;  you can redistribute it  and/or modify it under 
# terms of the  GNU General Public License as published  by the Free Soft- 
# ware  Foundation;  either version 2,  or (at your option) any later version. 
# PSIM is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY 
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
# for  more details.  
# You should have  received  a copy of the GNU General Public License  
# distributed with PSIM;  see file COPYING.  If not, write to the 
# Free Software Foundation,  59 Temple Place - Suite 330,  Boston, 
# MA 02111-1307, USA.                                                     
#
#
tmp=/tmp/display.$$
trap 'rm -f "${tmp}" >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 15

file=""
phase=0.0
T=0

for i in $* ; do
   case "$1" in
    -*=*) optarg=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;;
       *) optarg= ;;
   esac

   case $1 in
       --config=* )
	   config=$optarg
           ;;
           
       --phase=* )
           phase=$optarg
           ;;

       --image=*)
           image=${optarg}
	   ;;
           
       --T=*)
           T=$optarg
           ;;
           
   
       *) 
           if [ "x${rest}" = "x" ] ; then
              rest="$1"
           else
              rest="${rest} $1"
           fi
           ;;
   esac
   shift
done

vizdir=`pwd`
home=`dirname ${vizdir}`
script=paraview.net

if [ ! -e ${script} ] ; then
	Error "The script has to be called from the place where the dx script is located."
	exit 1:
fi

if [ -z "${image}" ] ; then
   image=${vizdir}/${config}.jpg
fi

file=${config}.tiff

## setup working environment in tmp in order speed up access
mkdir -p ${tmp}
cp ${home}/cfg/${config}.cfg ${tmp}
cd ${tmp}
##
${home}/bin/main ${config} ${phase} ${T} 
cp ${config}.data display.input
(
echo "Info;Data"
echo "${config} T=${T} ${phase} deg;Test"
) > annotation.input

dx -processors 7 -script ${vizdir}/${script}

cd ${home}
tifftopnm ${tmp}/display.tiff | pnmtojpeg > ${image}
##rm -rf ${tmp}


