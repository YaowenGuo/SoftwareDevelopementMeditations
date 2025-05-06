qemu-system-aarch64 -L /Users/lim/Library/Containers/com.utmapp.UTM/Data/Library/Caches/qemu 

-spice unix=on,addr=100EB03B-8AA0-423A-9932-D3545AC7EDC0.spice,disable-ticketing=on,image-compression=off,playback-compression=off,streaming-video=off,gl=off 

-chardev spiceport,name=org.qemu.monitor.qmp.0,id=org.qemu.monitor.qmp -mon chardev=org.qemu.monitor.qmp,mode=control 
-nodefaults 
-vga none 
-device virtio-net-pci,mac=2A:EB:BB:19:4C:1D,netdev=net0 -netdev vmnet-shared,id=net0 
-nographic 
-chardev spiceport,id=term0,name=com.utmapp.terminal.0 
-serial chardev:term0 
-cpu host 
-smp cpus=4,sockets=1,cores=4,threads=1 
-machine virt -accel hvf \
-drive if=pflash,format=raw,unit=0,file.filename=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Library/Caches/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on \
-drive if=pflash,unit=1,file=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/Linux.utm/Data/efi_vars.fd \
-m 16384 -audiodev spice,id=audio0 -device intel-hda -device hda-duplex,audiodev=audio0 -device nec-usb-xhci,id=usb-bus -device usb-tablet,bus=usb-bus.0 -device usb-mouse,bus=usb-bus.0 -device usb-kbd,bus=usb-bus.0 -device qemu-xhci,id=usb-controller-0 -chardev spicevmc,name=usbredir,id=usbredirchardev0 -device usb-redir,chardev=usbredirchardev0,id=usbredirdev0,bus=usb-controller-0.0 -chardev spicevmc,name=usbredir,id=usbredirchardev1 -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1,bus=usb-controller-0.0 -chardev spicevmc,name=usbredir,id=usbredirchardev2 -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2,bus=usb-controller-0.0 -device virtio-blk-pci,drive=drive8B610956-0C53-4EE5-800D-0CD978273073,bootindex=0 -drive if=none,media=disk,id=drive8B610956-0C53-4EE5-800D-0CD978273073,file.filename=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/Linux.utm/Data/8B610956-0C53-4EE5-800D-0CD978273073.qcow2,discard=unmap,detect-zeroes=unmap -device usb-storage,drive=driveB2467805-A2C3-45C2-B3EF-D176EA0626D4,removable=true,bootindex=1,bus=usb-bus.0 -drive if=none,media=cdrom,id=driveB2467805-A2C3-45C2-B3EF-D176EA0626D4,readonly=on -device virtio-serial -device virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0 -chardev spiceport,name=org.qemu.guest_agent.0,id=org.qemu.guest_agent -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 -chardev spicevmc,id=vdagent,debug=0,name=vdagent -fsdev local,id=virtfs0,path=/Users/lim/projects/linux,security_model=mapped-xattr -device virtio-9p-pci,fsdev=virtfs0,mount_tag=share 
-name Linux 
-uuid 100EB03B-8AA0-423A-9932-D3545AC7EDC0 
-device virtio-rng-pci


  -device virtio-net-pci,mac=2A:EB:BB:19:4C:1D,netdev=net0 \
  -netdev vmnet-shared,id=net0 \
  

qemu-system-aarch64 \
  -L /Users/lim/Library/Containers/com.utmapp.UTM/Data/Library/Caches/qemu \
  -nodefaults \
  -vga none \
  -nographic \
  -serial mon:stdio \
  -cpu host \
  -smp cpus=4,sockets=1,cores=4,threads=1 \
  -machine virt \
  -accel hvf \
  -drive if=pflash,format=raw,unit=0,file.filename=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Library/Caches/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on \
  -drive if=pflash,unit=1,file=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/Linux.utm/Data/efi_vars.fd \
  -m 16384 \
  -device nec-usb-xhci,id=usb-bus \
  -device usb-tablet,bus=usb-bus.0 \
  -device usb-mouse,bus=usb-bus.0 \
  -device usb-kbd,bus=usb-bus.0 \
  -device qemu-xhci,id=usb-controller-0 \
  -device virtio-blk-pci,drive=drive8B610956-0C53-4EE5-800D-0CD978273073,bootindex=0 \
  -drive if=none,media=disk,id=drive8B610956-0C53-4EE5-800D-0CD978273073,file.filename=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/Linux.utm/Data/8B610956-0C53-4EE5-800D-0CD978273073.qcow2,discard=unmap,detect-zeroes=unmap \
  -device usb-storage,drive=driveB2467805-A2C3-45C2-B3EF-D176EA0626D4,removable=true,bootindex=1,bus=usb-bus.0 \
  -drive if=none,media=cdrom,id=driveB2467805-A2C3-45C2-B3EF-D176EA0626D4,readonly=on \
  -device virtio-rng-pci \
  -device virtio-serial \
  -name Linux \
  -uuid 100EB03B-8AA0-423A-9932-D3545AC7EDC0

qemu-system-aarch64 \
  -L /Users/lim/Library/Containers/com.utmapp.UTM/Data/Library/Caches/qemu \
  -nodefaults \
  -vga none \
  -nographic \
  -serial mon:stdio \
  -cpu host \
  -smp cpus=4,sockets=1,cores=4,threads=1 \
  -machine virt \
  -accel hvf \
  -drive if=pflash,format=raw,unit=0,file.filename=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Library/Caches/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on \
  -drive if=pflash,unit=1,file=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/Linux.utm/Data/efi_vars.fd \
  -m 16384 \
  -device nec-usb-xhci,id=usb-bus \
  -device usb-tablet,bus=usb-bus.0 \
  -device usb-mouse,bus=usb-bus.0 \
  -device usb-kbd,bus=usb-bus.0 \
  -device qemu-xhci,id=usb-controller-0 \
  -device virtio-blk-pci,drive=drive8B610956-0C53-4EE5-800D-0CD978273073,bootindex=0 \
  -drive if=none,media=disk,id=drive8B610956-0C53-4EE5-800D-0CD978273073,file.filename\
=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/UbuntuClud.utm/Data/9D91105E-3223-4279-994A-7418C272127B.img,discard=unmap,detect-zeroes=unmap \
  -device virtio-blk-pci,drive=drive8B610956-0C53-4EE5-800D-0CD978273074,bootindex=1 \
  -drive if=none,media=disk,id=drive8B610956-0C53-4EE5-800D-0CD978273074,file.filename\
=/Users/lim/Library/Containers/com.utmapp.UTM/Data/Documents/UbuntuClud.utm/Data/9DD62D7C-8724-4DA6-AA62-17CE17F5880D.img,discard=unmap,detect-zeroes=unmap \
  -device virtio-rng-pci \
  -device virtio-serial \
  -name Linux \
  -uuid 100EB03B-8AA0-423A-9932-D3545AC7EDC0 \
  -device virtio-net-pci,mac=2A:EB:BB:19:4C:1D,netdev=net0 \
  -netdev vmnet-shared,id=net0