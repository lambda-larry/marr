#!/bin/bash

if [ -z "$MIRROR" ]; then
	exit 1;
fi

if [ -n "$HOSTNAME" ]; then
	echo "$HOSTNAME" > /etc/hostname
fi

cat << EOF > /etc/apt/sources.list
deb $MIRROR/ubuntu focal main restricted
deb $MIRROR/ubuntu focal multiverse
deb $MIRROR/ubuntu focal universe
deb $MIRROR/ubuntu focal-backports main restricted universe multiverse
deb $MIRROR/ubuntu focal-updates main restricted
deb $MIRROR/ubuntu focal-updates multiverse
deb $MIRROR/ubuntu focal-updates universe
deb $MIRROR/ubuntu focal-security main restricted
deb $MIRROR/ubuntu focal-security multiverse
deb $MIRROR/ubuntu focal-security universe
EOF

DELETE_PACKAGE=(
	man-db
	snapd
	nano
)

apt-get remove -y "${DELETE_PACKAGE[@]}"

apt-get update -y
apt-get upgrade -y

if [ -n "$PUBLIC_KEY" ]; then
	echo "$PUBLIC_KEY" | tee -a ~vagrant/.ssh/authorized_keys
fi
