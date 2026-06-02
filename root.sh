#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=x86_64
  ALPINE_VER_URL="https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/x86_64/alpine-minirootfs-3.22.0-x86_64.tar.gz"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=aarch64
  ALPINE_VER_URL="https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/aarch64/alpine-minirootfs-3.22.0-aarch64.tar.gz"
else
  printf "Unsupported CPU architecture: ${ARCH}\n"
  exit 1
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                  Foxytoux INSTALLER (Alpine 3.22)"
  echo "#"
  echo "#                           Copyright (C) 2026, RecodeStudios.Cloud"
  echo "#"
  echo "#######################################################################################"

  read -p "Do you want to install Alpine 3.22? (YES/no): " install_alpine
fi

case $install_alpine in
  [yY][eE][sS])
    echo "Downloading Alpine 3.22 rootfs..."
    curl -L -o /tmp/rootfs.tar.gz "$ALPINE_VER_URL"
    mkdir -p $ROOTFS_DIR
    tar -xf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
    ;;
  *)
    echo "Skipping Alpine installation."
    ;;
esac

if [ ! -e $ROOTFS_DIR/.installed ]; then
  mkdir -p $ROOTFS_DIR/usr/local/bin
  curl -L -o $ROOTFS_DIR/usr/local/bin/proot \
    "https://raw.githubusercontent.com/kof99zip/MyWorlds/main/proot-${ARCH}"

  while [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; do
    rm -f $ROOTFS_DIR/usr/local/bin/proot
    curl -L -o $ROOTFS_DIR/usr/local/bin/proot \
      "https://raw.githubusercontent.com/kof99zip/MyWorlds/main/proot-${ARCH}"
    sleep 1
  done

  chmod 755 $ROOTFS_DIR/usr/local/bin/proot
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  mkdir -p $ROOTFS_DIR/etc
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" > $ROOTFS_DIR/etc/resolv.conf
  touch $ROOTFS_DIR/.installed
fi

CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

display_gg() {
  echo -e ""
}

clear
display_gg

$ROOTFS_DIR/usr/local/bin/proot \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
