#!/bin/bash
set -e
go install github.com/go-task/task/v3/cmd/task@latest

cd site/themes && task && cd -

exec hugo --gc --minify