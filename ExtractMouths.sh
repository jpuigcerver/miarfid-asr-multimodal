#!/bin/bash

set -e

FILES=( `find data/original -regex .*/[0-9]+ | sort` )
ODIR=data/mouth2

for f in ${FILES[@]}; do
    dir=`dirname $f`;
    frame=`basename $f`;
    sent=`basename $dir`;
    user=`echo "$dir" | awk -F/ '{print $(NF-2)}'`;
    [ "${sent:0:4}" = "head" ] && { continue; }
    pref_dir=$ODIR/${user}_${sent}
    mkdir -p $pref_dir
    old=( `find ${pref_dir} -name $frame*` );
    [ ${#old[@]} -ne 0 ] && { continue; }
    echo $f
    ./extract_mouth $f ${pref_dir}/$frame
done

exit 0