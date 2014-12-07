#!/usr/bin/env python
from glob import glob
from wand.image import Image

import os, sys
from subprocess import Popen

anim_out = 'ios-icons-dock.gif'
anim_delay = 100

def make_anim():
    paths = glob('*.png')
    image = Image(filename=paths[0])
    anim = image.convert('gif')
    for p in paths[1:]: anim.sequence.append(
                Image(filename=p).convert('gif'))
    
    # lined up manually for once off capture
    anim.crop(left=80, top=1030, width=585, height=140)
    import IPython
    IPython.embed()
    save(anim)

def save(anim):
    anim.save(filename=anim_out)   
    optimize(anim_out)

def optimize(path):
    tmpfile = 'tmp.gif'
    os.rename   (anim_out, tmpfile)
    p = Popen(['gifsicle', '--optimize',                           
                            '--dither', '--colors', str(32),
                           '--delay', str(anim_delay), 
                           tmpfile, '-o', anim_out])
    p.wait()
    os.remove(tmpfile)

if __name__ == '__main__':
    make_anim()