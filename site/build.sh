#!/bin/bash
set -e

function clone {
	path=$1
	url=$2

	if [ ! -d "$path" ]; then
		git clone --depth=1 $url.git $path
	fi
}

clone themes/LoveIt https://github.com/dillonzq/LoveIt

rsync -a ./patch/ ./

hugo --gc --minify $@