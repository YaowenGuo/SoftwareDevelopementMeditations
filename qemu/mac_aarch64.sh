#/usr/bin/env bash

# Hardware Acceleration (Hypervisor)
# ACCEL="-accel hvf"

# System Specs
MACHINE="-machine virt,accel=hvf"
CPU="-cpu host -smp cpus=8,"
MEMORY="-m 16G"
NAME="-name LFS"
# Don’t create default devices.
# -nodefaults

# Boot
# -L path
# Set the directory for the BIOS, VGA BIOS and keymaps.
# To list all the data directories, use -L help.
BOOT_DIR="-L /opt/homebrew/Cellar/qemu/8.2.1/share/qemu" # /Applications/UTM.app/Contents/Resources/qemu 
# -drive if=pflash,format=raw,unit=0,file.filename=/Applications/UTM.app/Contents/Resources/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on
FRAMEWARE="-drive if=pflash,format=raw,unit=0,file.filename=/opt/homebrew/Cellar/qemu/8.2.1/share/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on"
# FRAMEWARE_VAR
FRAMEWARE_VAR="-drive if=pflash,format=raw,unit=1,file=/opt/homebrew/Cellar/qemu/8.2.1/share/qemu/edk2-arm-vars.fd"
# -S Do not start CPU at startup (you must type ‘c’ in the monitor).
# -S
BOOT="${BOOT_DIR} ${FRAMEWARE} ${FRAMEWARE_VAR}"

# Device
# Display。VGA 显示器老式15针接口
DISPLAY="-device virtio-gpu-pci -vga none"
# USB bus
BUS="-device nec-usb-xhci,id=usb-bus"
STARTUP_DISK="-device usb-storage,drive=drive9FA36442-38C1-46A6-932F-390611AA5DEB,removable=true,bootindex=0,bus=usb-bus.0 -drive if=none,media=cdrom,id=drive9FA36442-38C1-46A6-932F-390611AA5DEB,file=/Users/lim/Downloads/Fedora-Workstation-Live-aarch64-39-1.5-respin.iso,readonly=on"
KEYBOARD="-device usb-kbd,bus=usb-bus.0"
MOUSE="-device usb-mouse,bus=usb-bus.0"
TOUCHPAD="-device usb-tablet,bus=usb-bus.0"
DISK="-device virtio-blk-pci,drive=drive2BC0901F-DA56-49C7-A0D2-98F71114CB44,bootindex=1 -drive if=none,media=disk,id=drive2BC0901F-DA56-49C7-A0D2-98F71114CB44,file=$HOME/Project/Containers/FedoraArm64.qcow2,discard=unmap,detect-zeroes=unmap"
# NET="-device virtio-net-pci,mac=3A:F0:6E:23:0C:A4,netdev=net0 -netdev vmnet-shared,id=net0"
OTHER="-device virtio-rng-pci"
DEVICES="${DISPLAY} ${BUS} ${STARTUP_DISK} ${KEYBOARD} ${MOUSE} ${TOUCHPAD} ${DISK} ${NET}"

qemu-system-aarch64 ${ACCEL} ${MACHINE} ${CPU} ${MEMORY} ${NAME} ${BOOT} ${DEVICES} ${OTHER} $*


# Mac homebrew 仓库的 qemu 不带 spice，使用需要自己编译。
# -uuid 55810793-DA45-4990-8DB5-76D6B5319E0A
# ; 添加一块 virtio-serial 设备
# -device virtio-serial
# ; 使用 Unix 套接字进行 spice 频道的监听
# -spice unix=on,addr=55810793-DA45-4990-8DB5-76D6B5319E0A.spice,disable-ticketing=on,image-compression=off,playback-compression=off,streaming-video=off,gl=off
# ; QEMU机器协议（QMP）是一个基于JSON格式的协议，使得其他应用程序可以通过该协议控制QEMU实例
# -chardev spiceport,id=org.qemu.monitor.qmp,name=org.qemu.monitor.qmp.0 -mon chardev=org.qemu.monitor.qmp,mode=control 
# ; qemu guest agent简称qga， 是在虚拟机中运行的守护进程，他可以管理应用程序，执行宿主机发出的命令。例如冻结或解冻文件系统，使系统进入挂起状态等。
# -device virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0 -chardev spiceport,id=org.qemu.guest_agent,name=org.qemu.guest_agent.0

# ; QEMU provides its own implementation of the spice vdagent chardev called qemu-vdagent. It interfaces with the spice-vdagent guest service and allows the guest and host share a clipboard.
# ; 在 virtio-serial 设备上为 spice vdagent 打开一个端口。
# -device virtserialport,chardev=vdagent,name=com.redhat.spice.0
# ; 为该端口添加一块 spicevmc 字符设备
# -chardev spicevmc,id=vdagent,debug=0,name=vdagent

# ; 使用 SPICE 进行 USB 重定向。将USB设备从客户端重定向至虚拟机中，无需使用QEMU命令。
# -device qemu-xhci,id=usb-controller-0 
# -chardev spicevmc,name=usbredir,id=usbredirchardev0 
# -device usb-redir,chardev=usbredirchardev0,id=usbredirdev0,bus=usb-controller-0.0
# -chardev spicevmc,name=usbredir,id=usbredirchardev1 
# -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1,bus=usb-controller-0.0
# -chardev spicevmc,name=usbredir,id=usbredirchardev2 
# -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2,bus=usb-controller-0.0