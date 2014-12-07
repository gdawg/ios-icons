#!/bin/bash
getBusted(){
	echo "http://olivinelabs.com/busted/"
	exit 1
}

build(){
	echo "building..."
	luarocks make	> build.log
	rc=$?
	[[ rc -ne 0 ]] && cat build.log
	return $rc
}

gobust(){
  echo "quisemoi 1sec"
	cat ../tests.lua |sed 's/require "ios-icons"/require "ios-icons.tiger-blood"/' \
		> tests_default.lua

	echo "testing..."
	busted tests_default.lua
	busted tests.lua
}

clear
which busted >/dev/null 2>&1 || getBusted
build && gobust
