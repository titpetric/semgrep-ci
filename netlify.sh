#!/bin/bash
set -e
GOBIN=/usr/local/bin go install github.com/go-task/task/v3/cmd/task@latest

cd site/themes && task && cd -

cd site
exec hugo --gc --minify