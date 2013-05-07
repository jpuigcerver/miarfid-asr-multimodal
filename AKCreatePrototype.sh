#!/bin/bash
# Used to create a HMM prototype
set -e

FEATURES=data/train_audio_features.lst
PHONEMES=data/train.phonemes
DIM=39
OUT=audio_model.proto
NS=3

function usage () {
    cat <<EOF
Usage: $0 [OPTIONS]
Options:
    -h                  show this help message
    -f <features-lst>   list of feature files. default: $FEATURES
    -p <phonemes-lst>   list of phonemes. default: $PHONEMES
    -d <feat-dim>       features dimensionality. default: $DIM
    -n <num-states>     number of HMM states. default: $NS
    -o <output-proto>   output proto. default: $OUT
EOF
}

while [ "${1:0:1}" = "-" ]; do
    case "$1" in
        -h)
            usage; exit 0;
            ;;
        -f)
            FEATURES="$2"; shift 2;
            ;;
        -p)
            PHONEMES="$2"; shift 2;
            ;;
        -d)
            DIM="$2"; shift 2;
            ;;
        -o)
            OUT="$2"; shift 2;
            ;;
        -n)
            NS="$2"; shift 2;
            ;;
        *)
            echo "Unknown option: $1"; exit 1;
    esac
done

TMP=/tmp/audio_proto_$$

tLmkproto DGaussian $FEATURES $DIM -o $TMP
VAR=( `grep VAR $TMP` )
MU=( `grep MU $TMP` )
N=`cat $PHONEMES | wc -l`
{
    echo "AMODEL"
    echo "DGaussian"
    echo "D $DIM"
    echo -n "SMOOTH "
    echo ${VAR[@]} | awk '{ for(i=2;i<=NF; i++) { printf("%f ", $i * 0.001);}}'
    echo ""
    echo "N $[N+1]"
    for p in $(< $PHONEMES); do
        echo "'$p'"
        echo "Q $NS"
        echo -n "Trans"
        for i in `seq 1 $NS`; do echo -n " -0.916291"; done
        echo ""
        for i in `seq 1 $NS`; do
            echo "${MU[@]}"
            echo "${VAR[@]}"
        done
    done
    # Add special HMM for SP
    echo "'SP'"
    echo "Q 1"
    echo "TransL"
    echo "I"
    echo "1 -0.510826"
    echo "F -0.916291"
    echo "."
    echo "1"
    echo "1 -0.510826"
    echo "F -0.916291"
    echo "."
    echo "${MU[@]}"
    echo "${VAR[@]}"
} > $OUT

exit 0