#!/bin/bash

set -euox pipefail

sudo xcode-select -s /Applications/Xcode_14.3.app/Contents/Developer

xcrun --sdk macosx --show-sdk-path
xcrun --sdk macosx --show-sdk-platform-path
xcrun --sdk macosx --show-sdk-version
xcrun --sdk macosx --show-sdk-build-version
sw_vers
arch

wget https://github.com/zmanji/reproducible-wheel-builder/releases/download/v0.0.4/main.pex
chmod +x main.pex


wget https://files.pythonhosted.org/packages/6a/30/a727bb1420076b3c14b60911d111f0fc0449d31a1123a1ad18878a7a4e40/peewee-3.17.0.tar.gz
tar xvzf peewee-3.17.0.tar.gz

for py in python3.10 python3.11 python3.12
do
  MACOSX_DEPLOYMENT_TARGET=11.0 PEX_PYTHON=$(which $py) SOURCE_DATE_EPOCH=0 \
    ./main.pex --lock setuptools.lock --src ./peewee-3.17.0 --out ./out --dist wheel
done
