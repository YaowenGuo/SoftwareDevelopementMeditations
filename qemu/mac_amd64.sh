#/usr/bin/env bash

# Hardware Acceleration (Hypervisor)
ACCEL="-accel hvf"

# System Specs
NAME="-name LFS"
MACHINE="-machine virt"
CPU="-cpu host -smp cpus=8,"
MEMORY="-m 16G"

# Disks
DEVICES="-device usb-kbd -device usb-mouse"
USB=""
STARTUP_DISK=""

  
-drive if=none,file=${INSTALL_IMAGE_PATH},format=qcow2,id=hd0 \
-device virtio-blk-device,drive=hd0,serial="main_disk" \
-cdrom ${VM_DISK_PATH} \

# Devices
-device usb-ehci  \
-device usb-kbd \
-usb \

# Network
-device virtio-net-device,netdev=net0 \
-netdev user,id=net0 \

# Display
-device virtio-gpu \
-vga none \

# Serial & Terminal
-serial stdio

qemu-system-x86_64 ${ACCEL} ${MACHINE} ${CPU} ${MEMORY} ${DEVICES} $*