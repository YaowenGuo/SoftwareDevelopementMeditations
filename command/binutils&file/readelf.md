# readelf

```
readelf -h  hanoi
```
对于 Mac 的可执行文件
```
MachHeader {
  Magic: Magic64 (0xFEEDFACF)
  CpuType: X86-64 (0x1000007)
  CpuSubType: CPU_SUBTYPE_X86_64_ALL (0x3)
  FileType: Executable (0x2)
  NumOfLoadCommands: 17
  SizeOfLoadCommands: 1416
  Flags [ (0x200085)
    MH_DYLDLINK (0x4)
    MH_NOUNDEFS (0x1)
    MH_PIE (0x200000)
    MH_TWOLEVEL (0x80)
  ]
  Reserved: 0x0
}
```
即便是在 Mac 上，打印 Linux 的 ELF 文件

```
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x401040
  Start of program headers:          64 (bytes into file)
  Start of section headers:          13984 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         13
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 30
```