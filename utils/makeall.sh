#!/bin/bash
## make both ios-icons and the optional "tiger-blood" extensions
## usage: {app} [-f]
##
## note that luarocks "make" is really "make + make install"

usage(){
    grep '^##' $0 |cut -b4- |sed "s/{app}/$(basename $0)/g"
	exit 1
}

FORCE=0
case $1 in
	 "")
		;;
	-f|--force )
		FORCE=1
		;;
	* )
		usage
		;;
esac

ROOT=$(cd $(dirname $0)/..; pwd)
cd $ROOT

if [[ $FORCE -eq 1 ]]; then
	echo "removing existing install"
	luarocks list |grep ios-icons |while read rock; do
		luarocks remove --force $rock
	done

	rm -f ios-icons/*.so /tiger_blood/ios-icons/*.so
fi

luarocks make || exit $?

cd tiger_blood
luarocks make || exit $?
