#!/bin/bash

# This will only work on a Debian host

if ! command -v virt-customize &> /dev/null; then
  echo "virt-customize (guestfstools) must be installed"
  exit 1
fi

FILE_NAME=debian-12-generic-amd64.qcow2

if [ -f $FILE_NAME ]; then
  rm $FILE_NAME
fi

wget https://cloud.debian.org/images/cloud/bookworm/latest/$FILE_NAME

virt-customize --update --install qemu-guest-agent,neovim,sudo,nfs-common -a debian-12-generic-amd64.qcow2