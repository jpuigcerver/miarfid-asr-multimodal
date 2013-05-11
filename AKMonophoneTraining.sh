#!/bin/bash

set -e

FEATS=data/train_audio_features.lst
TRANS=data/train_phon_trans.lst
WDIR=work/train
PROTO=audio_model.proto
NG=64
EM_IT1=8
EM_IT2=4
FORCE=0
function usage () {
    cat <<EOF
Usage: $0 [OPTIONS]
Options:
    -h                  show this help message
    -f <features-lst>   list of feature files. default: $FEATS
    -t <transcr-lst>    list of phonetic transcription files. default: $TRANS
    -p <proto>          initial HMM prototype. default: $PROTO
    -g <num-gauss>      number of gaussian mixtures. default: $NG
    -D <wdir>           work directory: $WDIR
    -i1 <iters>         EM iterations for the 1-Gaussian HMMs
    -i2 <iters>         EM iterations for each of the HMMs reestimations
    -ow                 overwrite existing files
EOF
}

while [ "${1:0:1}" = "-" ]; do
    case "$1" in
        -h)
            usage; exit 0;
            ;;
        -f)
            FEATS="$2"; shift 2;
            ;;
        -t)
            TRANS="$2"; shift 2;
            ;;
        -p)
            PROTO="$2"; shift 2;
            ;;
        -g)
            NG="$2"; shift 2;
            ;;
        -D)
            WDIR="$2"; shift 2;
            ;;
        -i1)
            EM_IT1="$2"; shift 2;
            ;;
        -i2)
            EM_IT2="$2"; shift 2;
            ;;
        -ow)
            FORCE=1; shift 1;
            ;;
        *)
            echo "Unknown option: $1"; exit 1;
    esac
done

# 1-Gaussian
mkdir -p $WDIR/NG1
echo "Training for 1 gaussian..."
if [ ! -f $WDIR/NG1/amodel -o $FORCE -eq 1 ]; then
    tLtrain -v -m $EM_IT1 -o $WDIR/NG1/amodel $PROTO $TRANS $FEATS
    # Convert to Gaussian mixture
    tLtomix -i $WDIR/NG1/amodel -o $WDIR/NG1/amodel
fi

# Train gaussian mixtures
cc=2; pc=1
while [ $cc -le $NG ]; do
    PD=$WDIR/NG${pc}
    CD=$WDIR/NG${cc}
    mkdir -p $CD
    echo "Training for $cc gaussians..."
    if [ ! -f $CD/amodel -o $FORCE -eq 1 ]; then
        tLmumix -v -i $PD/amodel -o $CD/amodel 0
        tLtrain -v -m $EM_IT2 -o $CD/amodel $CD/amodel $TRANS $FEATS
    fi
    pc=$cc; cc=$[2 * cc];
done

exit 0