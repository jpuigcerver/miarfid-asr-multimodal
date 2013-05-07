#!/usr/bin/env python2.6
# -*- coding: utf-8 -*-
from sys import argv, stderr, stdout
from os import listdir
from os.path import normpath, basename, isdir
from re import sub
import cv
import numpy as np

DCT_H = 10
DCT_W = 10

def Usage():
    stdout.write('Usage: %s <dir>\n' % argv[0])
    stdout.write('Filter mouth images in "dir"\n')

def GetDCT(f):
    imMat = cv.LoadImageM(f, cv.CV_LOAD_IMAGE_GRAYSCALE)
    oH, oW = imMat.height, imMat.width
    H, W = oH, oW
    if H % 2 != 0: H = H + 1
    if W % 2 != 0: W = W + 1
    imMatF = np.zeros((H,W), np.float32)
    imMatF[:oH, :oW] = imMat
    imMatF = imMatF / 255.0
    dctMat = np.zeros((H,W), np.float32) #cv.CreateMat(H, W, cv.CV_32F)
    cv.DCT(imMatF, dctMat, cv.CV_DXT_FORWARD)
    return dctMat
    
def LoadImagesPaths(idir):
    data = {}
    for sent in listdir(idir):
        dp = normpath('%s/%s' % (idir, sent))
        if not isdir(dp): continue
        imgs = [normpath('%s/%s' % (dp,f)) for f in listdir(dp)]
        for f in imgs:
            fr = sub(r'.png', r'', basename(f)).split('_')[0]
            sent_frames = data.get(sent, {})
            frame_imgs = sent_frames.get(fr, [])
            frame_imgs.append(f)
            sent_frames[fr] = frame_imgs
            data[sent] = sent_frames
    return data

def GetUnambiguousImages(data):
    unambig = {}
    for (sent,frames) in data.items():
        user = sent.split('_')[0]
        for (frame, imgs) in frames.items():
            if len(imgs) == 1:
                dct = np.array(
                    reduce(lambda x,y: x+y, 
                           GetDCT(imgs[0])[:DCT_H,:DCT_W].tolist(), 
                           []))
                user_sents = unambig.get(user, {})
                sent_frames = user_sents.get(sent, {})
                sent_frames[imgs[0]] = dct
                user_sents[sent] = sent_frames
                unambig[user] = user_sents
    return unambig

def ShowImage(img):
    cv.ShowImage('winner_img', cv.LoadImage(img))

def AvgDist(img, protos):
    return sum([np.linalg.norm(img - p) for p in protos]) / len(protos)

def MinDist(img, protos):
    return min([np.linalg.norm(img - p) for p in protos])

def FilterImages3(imgs, sent_frames):
    """Select the best image comparing each candidate to the
    rest of unambiguous frames in the sentence."""
    min_d = float("inf")
    min_img = None
    for img in imgs:
        dct = np.array(
                reduce(lambda x,y: x+y, 
                       GetDCT(img)[:DCT_H,:DCT_W].tolist(),
                       []))
        d = AvgDist(dct, sent_frames)
        if d < min_d:
            min_d, min_img = d, img
    return min_img

def FilterImages2(imgs, user_sents):
    frames = reduce(lambda x,y: x+y, [s.values() for s in user_sents], [])
    return FilterImages3(imgs, frames)

def FilterImages1(imgs, unambig):
    stderr.write('Not implemented!\n')
    exit(1)

def FilterImages(data, unambig):
    for (sent, frames) in data.items():
        user = sent.split('_')[0]
        for (frame, imgs) in frames.items():
            if len(imgs) == 1:
                print imgs[0]
            elif user not in unambig: 
                print FilterImages1(imgs, unambig)
            elif sent not in unambig[user]:
                print FilterImages2(imgs, unambig[user].values())
            else:
                print FilterImages3(imgs, unambig[user][sent].values())
    return filtered_images

def main():
    if len(argv) == 0:
        Usage()
        return 1
    data = LoadImagesPaths(argv[1])
    unambig = GetUnambiguousImages(data)
    FilterImages(data, unambig)
    return 0

if __name__ == '__main__':
    exit(main())
