#!/bin/bash

cat <<EOF > metadata.yml
Name: $(head -1 debian/changelog | cut -d' ' -f1)
Version: $(head -1 debian/changelog | grep -Eo '[0-9]+(\.[0-9]+){1,}(-[0-9]+(\.[0-9]+){0,})?')
Arch: all $DEB_ARCH
Variants: $(grep 'Package:' debian/control | awk '{print $2}' | xargs)
UdebVariants: $(grep -B 1 'Package-Type: udeb' debian/control | grep 'Package:' | awk '{print $2}' | xargs)
EOF
