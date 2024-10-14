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

# The sdists have c code that does not compile under python 3.12
# Instead work off the raw git repository instead with Cython in the env

# wget https://files.pythonhosted.org/packages/6a/30/a727bb1420076b3c14b60911d111f0fc0449d31a1123a1ad18878a7a4e40/peewee-3.17.0.tar.gz
# tar xvzf peewee-3.17.0.tar.gz

wget https://github.com/coleifer/peewee/archive/refs/tags/3.17.0.tar.gz
tar xvzf 3.17.0.tar.gz

# The pyproject toml incorrectly does not list Cython as a build dependency
# which means the sqlite exts will not be built.
# It currently looks like
#
# [build-system]
# requires = ["setuptools", "wheel"]

cat ./peewee-3.17.0/pyproject.toml

cat << EOF > ./peewee-3.17.0/pyproject.toml

[build-system]
requires = ["setuptools", "wheel", "Cython"]

EOF

cat ./peewee-3.17.0/pyproject.toml

for py in python3.11 python3.12 python3.13
do
  MACOSX_DEPLOYMENT_TARGET=11.0 PEX_PYTHON=$(which $py) SOURCE_DATE_EPOCH=0 \
    ./main.pex --lock setuptools.lock --src ./peewee-3.17.0 --out ./out --dist wheel
done
