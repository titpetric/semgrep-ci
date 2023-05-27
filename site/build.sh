#!/bin/bash

# install task
GOBIN=/opt/build/repo/site/bin go install github.com/go-task/task/v3/cmd/task@latest
export PATH=$PATH:/opt/build/repo/site/bin

# clone themes
cd themes && task && cd -

# run hugo build
hugo --gc --minify

exit 0