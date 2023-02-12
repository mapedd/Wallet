#!/bin/zsh
#say "i'm inside post test script"
#lsof -i :8080 -sTCP:LISTEN |awk 'NR > 1 {print $2}'|xargs kill -15
