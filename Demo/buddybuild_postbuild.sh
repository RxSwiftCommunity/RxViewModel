#!/bin/bash

set -e -o pipefail

## Run macOS Tests
echo "▸ Running macOS Tests"
echo "======================="
xcodebuild -quiet -workspace 'Demo.xcworkspace' -scheme 'RxViewModelTests-macOS' -configuration 'Debug' -sdk macosx -destination arch='x86_64' test | xcpretty -c --test

## Run tvOS Tests
echo "▸ Running tvOS Tests"
echo "======================="
xcodebuild -quiet -workspace 'Demo.xcworkspace' -scheme 'RxViewModelTests-tvOS' -configuration 'Debug' -sdk appletvsimulator10.2 -destination name='Apple TV 1080p' test | xcpretty -c --test