#!/bin/bash

source .env
source .build_env
ARCH=$DEB_TARGET_ARCH

# Update packages
apt update && apt upgrade -y

# Install build tools
apt install -y debhelper build-essential grep mawk

# Check for cross-compile
if [ "$ARCH" != $(dpkg --print-architecture) ]; then
  dpkg --add-architecture "$ARCH"
  apt update
  apt install -y crossbuild-essential-$ARCH
  DEB_BUILD_OPTIONS="nocheck $DEB_BUILD_OPTIONS"
  DEB_BUILD_PROFILES="cross nocheck $DEB_BUILD_PROFILES"
  DEB_BUILD_ARGS="-a$ARCH $DEB_BUILD_ARGS"
  export CONFIG_SITE=/etc/dpkg-cross/cross-config.$ARCH
fi

dependencies=""
for p in $(dpkg-checkbuilddeps 2>&1 | grep -i 'build dependencies' | awk -F ':' '{print $4}'); do
  case "$p" in '('* | *')') ;; *) dependencies="$dependencies $p:$ARCH" ;; esac
done
yes | apt install -y $dependencies || :

# Clean up apt cache
apt autoclean -y && rm -rf /var/lib/apt/lists/*

export DEBEMAIL DEBFULLNAME DEB_BUILD_OPTIONS DEB_BUILD_PROFILES

if [ "$GPG_SECRET" ]; then
  echo "$GPG_SECRET" | gpg --import
else
  DEB_BUILD_ARGS="--no-sign $DEB_BUILD_ARGS"
fi

source .build_env

# Build binary package
dpkg-buildpackage $DEB_BUILD_ARGS || exit 1

# Uninstall all dependencies
yes | apt autoremove --purge --allow-remove-essential -y debhelper build-essential $dependencies
