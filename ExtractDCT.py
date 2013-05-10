#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Extract DCT coefficients from the images in the list read through stdin.
# This is used to extract the main DCT coeff. from the selected mouth images.
# For each frame, a dct file is created as:
#    data/features/video/${USER_ID}/${SENT_ID}/${FRAME_ID}.dct
# This DCT files should be merged later with the audio features to generate
# the final Audio+Video features. Use AKAudioVideoFeatures.py for this.
from sys import argv, stderr, stdin
from os import system
from os.path import basename, dirname, exists
import cv
import numpy as np

def GetDCT(f):
    imMat = cv.LoadImageM(f, cv.CV_LOAD_IMAGE_GRAYSCALE)
    oH, oW = imMat.height, imMat.width
    H, W = oH, oW
    if H % 2 != 0: H = H + 1
    if W % 2 != 0: W = W + 1
    imMatF = np.zeros((H,W), np.float32)
    imMatF[:oH, :oW] = imMat
    imMatF = imMatF / 255.0
    dctMat = np.zeros((H,W), np.float32)
    cv.DCT(imMatF, dctMat, cv.CV_DXT_FORWARD)
    imMat = imMatF = None
    return dctMat

def main():
    DCT_H = 30
    DCT_W = 40
    a = 1
    while a < len(argv):
        if argv[a] == '-h': 
            DCT_H = int(argv[a+1])
            i += 2
        elif argv[a] == '-w': 
            DCT_W = int(argv[a+1])
            i += 2
        else:
            stderr.write('Unknown option: %s\n' % argv[a])
            return 1
            
    for fname in stdin:
        fname=fname.strip()
        if len(fname) == 0: continue
        f = basename(fname)[:3] # frame
        us = basename(dirname(fname)).split('_')
        u, s = us[0], us[1]
        dct = reduce(lambda x,y: x+y,
                     GetDCT(fname)[:DCT_H,:DCT_W].tolist(), [])
        odir = 'data/features/video/%s/%s' % (u, s)
        if not exists(odir):
            system('mkdir -p %s' % odir)
        fdct = open('%s/%s.dct' % (odir, f), 'w')
        for i in dct:
            fdct.write('%f\n' % i)
        fdct.close()
    return 0

if __name__ == '__main__':
    exit(main())
