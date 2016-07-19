#!/bin/bash

ROCKS=luarocks5.3

getBusted(){
	echo "http://olivinelabs.com/busted/"
	exit 1
}

build(){
	echo "building..."
	$ROCKS make	> build.log
	rc=$?
	[[ rc -ne 0 ]] && cat build.log
	return $rc
}

gobust(){
	echo "testing..."
	#busted tests.lua
	#busted --help
	busted 
}

which busted >/dev/null 2>&1 || getBusted
build && gobust
