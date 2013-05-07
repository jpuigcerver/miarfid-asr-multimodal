#!/bin/bash
# This script downloads the data from the vidTIMIT webpage.
set -e

HOST="http://itee.uq.edu.au/~conrad/vidtimit/zips/"
FILES=(
    fadg0.zip
    faks0.zip
    fcft0.zip
    fcmh0.zip
    fcmr0.zip
    fcrh0.zip
    fdac1.zip
    fdms0.zip
    fdrd1.zip
    fedw0.zip
    felc0.zip
    fgjd0.zip
    fjas0.zip
    fjem0.zip
    fjre0.zip
    fjwb0.zip
    fkms0.zip
    fpkt0.zip
    fram1.zip
    mabw0.zip
    mbdg0.zip
    mbjk0.zip
    mccs0.zip
    mcem0.zip
    mdab0.zip
    mdbb0.zip
    mdld0.zip
    mgwt0.zip
    mjar0.zip
    mjsw0.zip
    mmdb1.zip
    mmdm2.zip
    mpdf0.zip
    mpgl0.zip
    mrcz0.zip
    mreb0.zip
    mrgg0.zip
    mrjo0.zip
    msjs1.zip
    mstk0.zip
    mtas1.zip
    mtmr0.zip
    mwbt0.zip )

mkdir -p data/original
cd data/original

# Download data
for f in ${FILES[@]}; do
    [ -f $f ] && { continue; }
    echo $HOST$f
    wget -q $HOST$f
done

# Unzip data
for f in ${FILES[@]}; do
    fdir=${f/.zip/}
    echo $fdir
    [ -d $fdir ] && { continue; }
    unzip $f
    chmod 755 $fdir
    chmod 755 $fdir/audio
    chmod 755 $fdir/video
    chmod 755 $fdir/video/*
done

exit 0