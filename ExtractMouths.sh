#!/bin/bash

set -e

#FILES=( `find data/original -regex .*/[0-9]+ | sort` )
ODIR=data/mouth

for f in $(< video_frames); do #{FILES[@]}; do
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
    minN=150
    while [ $minN -gt 0 -a ${#old[@]} -eq 0 ]; do
        echo ./extract_mouth --min-neighs=$minN $f ${pref_dir}/$frame
        ./extract_mouth --min-neighs=$minN $f ${pref_dir}/$frame
        old=( `find ${pref_dir} -name $frame*` );
        minN=`python -c "print int($minN * 0.7)"`
    done
done

exit 0
