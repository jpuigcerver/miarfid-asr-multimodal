#!/usr/bin/env python
# -*- coding: utf-8 -*-
# This script is useful to generate a bunch of files related to the
# audio transcriptions, which are needed by AKToolkit to train and 
# test an ASR system.
# The output of the script are the word transcriptions for each input
# file. This is useful to generate the ground truth files, so the script
# should be executed one time for each data partition.
#
# Usage: AKCreateTranscFiles.py \
#        [<word-transc-files-list>] \
#        [<phon-transc-files-list>] \
#        [<tltoolkit-lexicon>] \
#        [<used-phonemes-list>]
#
# A list of feature files is read from stdin and its phonetic and word
# transcriptions are generated in files of the following form:
#   data/trans/${USER_ID}/${SENT_ID}_[phon|word].txt
# The generated files are stored in the <[phon|word]-transc-files-list>
# indicated by the user as arguments.
# Additionally, <tltoolkit-lexicon> specifies a file where the TIMIT 
# lexicon will be stored in the AKToolkit format.
# Finally, <used-phonemes-list> contains a list of all used phonemes.

from sys import argv, exit, stdin
from re import sub
from os import system

# Load the TIMIT transcriptions
TIMIT={}
f = open('data/TIMIT_SENTENCES.TXT', 'r')
for l in f:
    l = l.split()
    sid = l[0]
    sent = l[1:]
    TIMIT[sid] = sent
f.close()

# Load the TIMIT lexicon
W2P={}
f = open('data/TIMIT_DICT.TXT', 'r')
for l in f:
    l = sub(r'(~[a-z]+|\/)', r'', l)
    l = l.strip().split()
    if l[0][0] == ';': continue
    w = l[0]
    p = l[1:]
    W2P[w] = p
f.close()

word_trans_lst = None
if len(argv) > 1:
    word_trans_lst = open(argv[1], 'w')

# List of files containing the transcriptions
# of each sample
phon_trans_lst = None
if len(argv) > 2:
    phon_trans_lst = open(argv[2], 'w')

USED_PHONS=set()
USED_WORDS=set()
for l in stdin:
    l = l.strip().split('/')
    user = l[-2]
    sent = sub(r'\.fea', r'', l[-1])
    sid = sent[2:]
    system('mkdir -p data/trans/%s' % user)
    # Create word transcription file
    if word_trans_lst is not None:
        word_trans_lst.write('data/trans/%s/%s_word.txt\n' % (user, sent))
    f = open('data/trans/%s/%s_word.txt' % (user, sent), 'w')
    f.write('%s\n' % ' '.join(TIMIT[sid]))
    f.close()
    # Create phonetic transcription file
    if phon_trans_lst is not None:
        phon_trans_lst.write('data/trans/%s/%s_phon.txt\n' % (user, sent))
    f = open('data/trans/%s/%s_phon.txt' % (user, sent), 'w')
    pt = ['SP']
    USED_WORDS.update(TIMIT[sid])
    for w in TIMIT[sid]:
        USED_PHONS.update(W2P[w])
        pt = pt + W2P[w] + ['SP']
    f.write('%s\n' % ' '.join(pt))
    f.close()
    # Print word-level transcription, used as GT
    print ' '.join(TIMIT[sid])

# LEXICON file for AKToolkit
if len(argv) > 3:
    words = [w for w in USED_WORDS]
    words.sort()
    f = open(argv[3], 'w')
    f.write('LEXICON\n')
    for w in words:
        f.write('%-25s %-4f %s\n' % (w, 0.0, ' '.join(W2P[w])))
    f.close()

# List of used phonemes
if len(argv) > 4:
    phons = [p for p in USED_PHONS]
    phons.sort()
    f = open(argv[4], 'w')
    for p in phons:
        f.write('%s\n' % p)
    f.close()

if phon_trans_lst is not None:
    phon_trans_lst.close()

if word_trans_lst is not None:
    word_trans_lst.close()
