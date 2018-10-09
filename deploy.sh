#!/usr/bin/env bash

set -eux

curl -o dart.zip https://storage.googleapis.com/dart-archive/channels/dev/release/2.1.0-dev.6.0/sdk/dartsdk-linux-x64-release.zip
unzip dart.zip

ls dart-sdk/bin

PUB=./dart-sdk/bin/pub
${PUB} global activate webdev
${PUB} get .
${PUB} global run webdev build --output=web:build
