#!/bin/zsh
say "i'm inside pre test script"
# cd $SRCROOT/Backend

# workspace_path = $WORKSPACE_PATH
# echo $workspace_path
# suffix = "Wallet.xcodeproj/project.xcworkspace"
# trimmed=${workspace_path"$suffix"}
# echo $trimmed

# echo $SRCROOT
#cd "Backend"
#lsof -i :8080 -sTCP:LISTEN | awk 'NR > 1 {print $2}' | xargs kill -15
#eval "$(/opt/homebrew/bin/brew shellenv)"
## & at the end should allow for the script to contonie as server will not finnish until it's turned off
#vapor run --env testing &
