#!/bin/bash
if [ -d "themes/ananke" ]; then
	echo "themes/ananke OK"
else
	git clone --depth=1 https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
fi

hugo --gc --minify $@