#!/bin/bash
set -e

# install task
GOBIN=/usr/local/bin go install github.com/go-task/task/v3/cmd/task@latest

# clone themes
cd themes && task && cd -

# exec hugo build
exec hugo --gc --minify