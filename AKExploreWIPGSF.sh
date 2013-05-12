#!/bin/bash

set -e
#GSF=(1 2 4 8 16 32 64)
#WIP=(-64 -32 -16 -8 -4 -2 -1 0 1)
#GSF=( 10 12 14 16 18 20 )
#WIP=(-32)
GSF=( 14 )
WIP=( -38 -36 -34 -32 -30 -28 -26 )

HMM=
LM=data/train.tL.lm
LEX=data/train.lexicon
FEATS=data/devel_audio_features.lst
BEAM=180
NMAX_STATES=20000
REF=data/devel.ref
VOC=data/train.vocab
while [ "${1:0:1}" = "-" ]; do
    case "$1" in
        -h)
            exit 0
            ;;
        -m)
            HMM="$2"; shift 2;
            ;;
        -g)
            GSF=(); shift 1;
            while [ $# -gt 0 -a "${1:0:1}" != "-" ]; do
                GSF=(${GSF[@]} "$1"); shift 1;
            done
            ;;
        -w)
            WIP=(); shift 1;
            while [ $# -gt 0 -a "${1:0:1}" != "-" ]; do
                WIP=(${WIP[@]} "-$1"); shift 1;
            done
            ;;
        -l)
            LM="$2"; shift 2;
            ;;
        -x)
            LEX="$2"; shift 2;
            ;;
        -f)
            FEATS="$2"; shift 2;
            ;;
        -b)
            BEAM="$2"; shift 2;
            ;;
        -s)
            NMAX_STATES="$2"; shift 2;
            ;;
        -r)
            REF="$2"; shift 2;
            ;;
        -v)
            VOC="$2"; shift 2;
            ;;
        *)
            echo "Unknown option: $1" >&2; exit 1;
    esac
done

[ "$HMM" = "" ] && { echo "Acustic model expected. Use -m <model>." >&2; exit 1; }

WDIR=`dirname $HMM`;
function run_exper () {
    FN=`basename $FEATS`
    HYP=$WDIR/${FN}_GSF${1}_WIP${2}_BEAM_${BEAM}.hyp
    LOG=$WDIR/${FN}_GSF${1}_WIP${2}_BEAM_${BEAM}.log
    tLrecognise -v -s SP -l $LEX --beam $BEAM --nmax-astates $NMAX_STATES \
        --word-end-pruning 90 --lookahead-capacity 1000 -g $1 -w $2 -o $HYP \
        $LM $HMM $FEATS &> $LOG
    echo "GSF=$1 WIP=$2"
    wer++.py -O $VOC $HYP $REF
}

for s in ${GSF[@]}; do
    for p in ${WIP[@]}; do
        run_exper $s $p
    done
done

exit 0
