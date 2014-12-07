# ios-icons - scripted iphone/ios icon arrangement
---

ios-icons is a [lua](http://www.lua.org/) module enabling communication 
with iPhone/iPod/iPad device(s) over usb for the purposes of icon arrangement.

## Usage

![demo repl session](caps/dock-set.gif)

### basics

`ios.connect` returns a connection for read / set operations.

    bash# lua
    Lua 5.2.3  Copyright (C) 1994-2013 Lua.org, PUC-Rio
    > ios = require "ios-icons"
    > conn = ios.connect()
    > icons = conn:get_icons()

`conn:get_icons()` returns a table model of the current 
icons as arranged on device (by page then (icon or group/icon). 

    > -- how many (springboard) pages do I have?
    > print(#icons)
    12

as well as the model objects, icons contains a bunch of utility methods,
like `flatten`, `find`, `visit` ...

    > -- how many icons do I have overall?
    > print(#icons:flatten())
    222

### updating the device

The simplest update you can make swaps two icon positions

    > print(icons:dock())
    pr0nz, Mail, 1Password, Safari
    >
    > -- wait - err, how'd that get there!
    > icons:swap(icons[1][1], icons:find("Messages"))
    > conn:set_icons(icons)
    >
    > print(conn:get_icons()[1])
    Messages, Mail, 1Password, Safari

see [example_sort](example_sort/README.md) and [source](lib) for more details.

## Requirements and Installation

Communication is via usb, using the excellent 
[libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) and
[libplist](https://github.com/libimobiledevice/libplist) libraries **both of
which are required to build**. 

#### osx install:

    brew install lua --with-completion
    brew install luarocks libimobiledevice libplist
    luarocks install ios-icons

#### linux install:

As well as osx I've tested on ubuntu (14.4) but the install was 
significantly more complicated due to incompatible libimobiledevice
versions in apt. 

I can't ascertain the politics or technical details of why 
libimobiledevice-2 exists, nor where it's source is hosted
online but it appears quite incompatible with the version of the lib
I've used, and the header files unfortunately conflict.

To work around this I built libimobiledevice, libplist and libusbmuxd from 
source, installed each with checkinstall. *Tread careful if you decide
to follow in my footsteps here - I don't use any of the Linux ios tooling
so may have broken rhythmbox/syncing/whatever the kids use these days and
I wouldn't even know.*

I used lua5.2 from apt and build luarocks from source (although I've since
forgotten what failure prompted the manual rocks build).
