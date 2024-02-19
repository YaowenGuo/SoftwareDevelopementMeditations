# QEMU

QEMU 可以作为虚拟机使用，得益于对系统虚拟化加速器的支持，可以在损失微小性能的情况下运行虚拟机。然而其能做的不止于此，正如其名**quick emulator**，它是一个支持多种硬件架构的**模拟器**，可以在宿主机上模拟出不同架构的CPU和外设，经常用于硬件驱动开发和操作系统开发、移植。

作为普通用户可能更加倾向于推荐使用 VmWare 或者 VirtualBox。但对于开发者来说掌握 QEMU 的优势明显，大多数情况下是开发场景只有 QEMU 合适，额外的收益是它还可以作为替代 VmWare 或者 VirtualBox 的虚拟机使用，得益于其对系统虚拟化加速器的良好支持（例如 Linux 的 KVM, Mac 的hvf），其性能甚至超过其它虚拟机。

Mac 上安装：https://medium.com/@aryangodara_19887/qemu-virt-manager-and-libvirt-on-macos-with-apple-silicon-m2-dc677e6b8559

## 使用

QEMU 只是一个命令行的后端，由于其指令参数比较复杂，官方推荐使用 GUI 工具来创建虚拟机，常用的有 VirtManager，GnomeBoxs. 这些虚拟机前端 GUI 可以利用特性探测来构建适合在硬件上运行的现代虚拟机映像。

QEMU 支持 **系统模拟**和**用户模式模拟**，系统模拟运行一个完成的系统，更像一个模拟器。用户模式模拟只支持 Linux 和 BSD 系统，更像一个容器，将运行程序和系统隔离。因此用户模式模拟不能模拟不同于宿主机架构的硬件以及系统。

然而对于开发者，了解命令参数可以帮助我们更好的配置开发环境，了解硬件。并在出现错误时更好的修复问题。

系统模拟和用户模拟的被分成了不同的命令。
系统模拟：
```
qemu-system-<arch> [option] <image>
```
`arch` 指出要模拟的客户机的架构。例如，想要模拟 arm64 系统，无论 是AMD64 机器还是 arm 机器，都是使用 `qemu-system-aarch64` 命令。
用户模式模拟：
```
qemu-<arch> [options ...]
```

## 系统模拟

QEMU命令行的一般形式可以表示为：
```shell
$ qemu-system-x86_64 [options] [disk_image]
```
磁盘映像是IDE硬盘0的原始硬盘映像。有些目标不需要磁盘映像。
```
$ qemu-system-x86_64 [machine opts] \
                [cpu opts] \
                [accelerator opts] \
                [device opts] \
                [backend opts] \
                [interface opts] \
                [boot opts]
```

`qemu` 的选项不区分 `-` 和 `--`, 可以使用 `-h` 查看帮助，或者 `-<opts> help` 查看某选项的帮助文档，将展示所有参数或可选值。例如
```
$ qemu-system-x86_64 -M help
```
列出所有的所支持的所有机器类型，help也可以作为参数传递给另一个选项。例如
```
$ qemu-system-x86_64 -device scsi-hd,help
```
将列出可以控制scsi-hd设备行为的其他选项的参数及其默认值。

## 启动镜像或内核

当指定了 machine 之后，基本就可以启动系统了，像 `x86_64` 架构甚至可以不指定机器，有默认的值，直接运行操作系统。使用QEMU引导系统大致有4种方式。

- 指定一个固件，并让它控制查找内核。
- 指定一个固件，并向内核传递要引导的提示
- 直接内核映像引导
- 手动将文件加载到来客户机地址空间


### 指定固件



## 设备模拟

QEMU向客座机器提供虚拟/模拟的硬件设备，使其与外部世界进行交互，就像它在真实硬件上运行一样。QEMU 支持大量设备的仿真，从外设(如网卡和USB设备)到集成的片上系统(SoCs)。它们的配置通常是混淆的来源之一，了解 QEMU 中用于描述的设备的一些术语会有所帮助。

- 设备前端(-device): 设备前端是在虚拟机中呈现的设备形式。所呈现的设备类型应该与虚拟机中操作系统期望看到的硬件相匹配。所有设备都通过 `--device` 命令行选项指定。使用命令行选项 `--device foo,help` 将列出该设备可用的其他配置选项。前端通常与后端配对，后端描述了主机的资源在模拟中如何使用。后端有时可以堆叠以实现快照等功能。

- 设备后端(-chardev 和 -blockdev): 后端描述了来自仿真设备的数据如何有 QEMU 处理。后端的配置通常根据被模拟的设备的类别而定。例如，串行设备将由 -chardev 支持，它可以将数据重定向到文件、套接字或其他类型。存储设备由 `-blockdev` 处理，它将指定如何处理块，例如存储在 qcow2 文件中或访问主机的原始磁盘分区。

    由于选择的后端通常对模拟系统是透明的，在某些情况下，如果后端无法支持功能，并不会向客户机报告。

- 设备透传：设备透传是指设备直接获得对底层硬件的访问权限。这可以简单到将主机系统上的单个USB设备暴露给客户机，或者将PCI插槽中的视频卡专供客户机使用。

- 设备总线：大多数设备将存在于某种总线上。根据您选择的机器模型(-M foo)，许多总线被自动创建。在大多数情况下，可以推断出设备所连接的总线，例如 PCI 设备通常自动分配到找到的第一个 PCI 总线的下一个空闲地址。然而，在复杂的配置中，您可以显式地指定设备连接到哪个总线(bus=ID)及其地址(addr=N)。
    有些设备(例如PCI SCSI主机控制器)将向系统添加额外的总线，以便其他设备可以连接到这些总线上。假设的设备链是这样的：
    ```
    –device foo,bus=pci.0,addr=0,id=foo –device bar,bus=foo.0,addr=1,id=baz
    ```
这将一个 bar 设备(ID为baz)连接到地址为1的第一个foo总线(foo.0)。提供该总线的foo设备本身连接到第一个PCI总线(PCI.0)。

### -drive

定义一个新驱动器。这包括创建块驱动程序节点(后端)和客户机设备，并且主要是定义相应的-blockdev和-device 选项的快捷方式。-drive 接受 -blockdev接受的所有选项。

`-drive` 选项将设备和后端合并为一个命令行选项，这更人性化。然而，没有接口稳定性保证，尽管一些旧的板模型仍然需要更新才能与现代 blockdev 形式一起工作。

**`drive` 没有 help 选项的帮助文档，查看 -device 和 -blockdev 的帮助即可。**

### device

指定要在机器中使用的设备（包括外接设备，如 USB, Network Card, VGA, Sound Card 等），以及其它选项。

type `-device help` to get a list of all devices

Useful Information You can add help as an option to any -device targets to get a list of all available options! 

```
$ qemu-system-x86_64 -device sd-card,help

# Output
> sd-card options:
>   drive=<str>            - Node name or ID of a block device to use as a backend
>   spec_version=<uint8>   -  (default: 2)
>   spi=<bool>             -  (default: false)
```

- Controller/Bridge/Hub
- USB devices
- Storage devices
- Network devices
- Input devices
- Display devices
- Sound devices
- Misc devices
- Watchdog devices
- Uncategorized devices
