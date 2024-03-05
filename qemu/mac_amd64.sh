#/usr/bin/env bash
# System Specs
MACHINE="-machine q35,accel=tcg"
CPU="-smp cpus=8"
MEMORY="-m 32G"
NAME="-name AMD64"

# Boot
# -L path
# Set the directory for the BIOS, VGA BIOS and keymaps.
# To list all the data directories, use -L help.
BOOT_DIR="-L /opt/homebrew/Cellar/qemu/8.2.1/share/qemu" # /Applications/UTM.app/Contents/Resources/qemu 
# -drive if=pflash,format=raw,unit=0,file.filename=/Applications/UTM.app/Contents/Resources/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on
FRAMEWARE="-drive if=pflash,format=raw,unit=0,file.filename=/opt/homebrew/Cellar/qemu/8.2.1/share/qemu/edk2-x86_64-code.fd,file.locking=off,readonly=on"
# FRAMEWARE_VAR
FRAMEWARE_VAR="-drive if=pflash,format=raw,unit=1,file=/opt/homebrew/Cellar/qemu/8.2.1/share/qemu/edk2-i386-vars.fd"
# -S Do not start CPU at startup (you must type ‘c’ in the monitor).
# -S
BOOT="${BOOT_DIR} ${FRAMEWARE} ${FRAMEWARE_VAR}"

# Device
# Display。VGA 显示器老式15针接口
DISPLAY="-device virtio-gpu-pci -vga none"
# USB bus
BUS="-device nec-usb-xhci,id=usb-bus"
STARTUP_DISK="-device usb-storage,drive=drive9FA36442-38C1-46A6-932F-390611AA5DEB,removable=true,bootindex=0,bus=usb-bus.0 -drive if=none,media=cdrom,id=drive9FA36442-38C1-46A6-932F-390611AA5DEB,file=/Users/lim/Downloads/ubuntu-23.10.1-desktop-amd64.iso,readonly=on"
KEYBOARD="-device usb-kbd,bus=usb-bus.0"
MOUSE="-device usb-mouse,bus=usb-bus.0"
TOUCHPAD="-device usb-tablet,bus=usb-bus.0"
DISK="-device virtio-blk-pci,drive=drive2BC0901F-DA56-49C7-A0D2-98F71114CB44,bootindex=1 -drive if=none,media=disk,id=drive2BC0901F-DA56-49C7-A0D2-98F71114CB44,file=$HOME/Project/Containers/FedoraArm64.qcow2,discard=unmap,detect-zeroes=unmap"
# NET="-device virtio-net-pci,mac=3A:F0:6E:23:0C:A4,netdev=net0 -netdev vmnet-shared,id=net0"
OTHER="-device virtio-rng-pci"
DEVICES="${DISPLAY} ${BUS} ${STARTUP_DISK} ${KEYBOARD} ${MOUSE} ${TOUCHPAD} ${DISK} ${NET}"

echo ${ACCEL} ${MACHINE} ${CPU} ${MEMORY} ${NAME} ${BOOT} ${DEVICES}

qemu-system-x86_64 ${ACCEL} ${MACHINE} ${CPU} ${MEMORY} ${NAME} ${BOOT} ${DEVICES} ${OTHER} $*