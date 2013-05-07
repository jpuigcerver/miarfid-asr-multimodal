#!/bin/bash
# This script generates the audio features in a proper format for AKToolkit.
# The extracted features are the default by tLextract (MFCC).

set -e
find data/original -name "*.wav" > data/audio_files.lst
for f in $(< data/audio_files.lst); do
    dir=`dirname $f`
    sent=`basename $f`; sent=${sent/.wav/};
    user=`dirname $dir`; user=`basename $user`;
    mkdir -p data/features/audio/$user
    echo data/features/audio/$user/$sent.fea
done > data/audio_features.lst

tLextract --noraw data/audio_files.lst data/audio_features.lst
