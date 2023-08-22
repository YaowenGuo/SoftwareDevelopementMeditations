# readelf

readelf 用于读取 elf 文件信息。llvm-readelf 是 llvm-readobj 的一个软链接。

```
USAGE: llvm-readelf [options] <input object files>
```

```

OPTIONS:
  -h --file-header                  Display file header
  -S --section-headers              Display section headers
  -s --syms --symbols               Display the symbol table. Also display the dynamic symbol table when using GNU output style for ELF
  -r --relocs --relocations         Display the relocation entries in the file
  -u --unwind                       Display unwind information
  -e --headers                      Equivalent to setting: --file-header, --program-headers, --section-headers
  -a --all                          Equivalent to setting: --file-header, --program-headers, --section-headers, --symbols, --relocations, --dynamic-table, --notes, --version-info, --unwind, --section-groups and --histogram

  --addrsig                         Display address-significance table
  -A --arch-specific                Display architecture-specific information

  --bb-addr-map                     Display the BB address map section
  --cg-profile                      Display call graph profile section
  -C --demangle                     Demangle symbol names
  --no-demangle                     Do not demangle symbol names (default)

  --dependent-libraries             Display the dependent libraries section
  --dyn-relocations                 Display the dynamic relocation entries in the file
  --dt--dyn-syms --dyn-symbols      Display the dynamic symbol table
  --expand-relocs                   Expand each shown relocation to multiple lines

  -x --hex-dump=<name or index>     Display the specified section(s) as hexadecimal bytes
  --pretty-print                    Pretty print JSON output
  --sd  --section-data              Display section data for each section shown. This option has no effect for GNU style output
  -t --section-details              Display the section details
  --section-mapping                 Display the section to segment mapping
  --sr --section-relocations        Display relocations for each section shown. This option has no effect for GNU style output
  --st --section-symbols            Display symbols for each section shown. This option has no effect for GNU style output
  --sort-symbols=<value>            Specify the keys to sort the symbols before displaying symtab
  --stack-sizes                     Display contents of all stack sizes sections. This option has no effect for GNU style output
  --stackmap                        Display contents of stackmap section
  -p --string-dump=<name or index>  Display the specified section(s) as a list of strings
  --wide                            Ignored for GNU readelf compatibility
  -W                                Ignored for GNU readelf compatibility

OPTIONS (ELF specific):
  -l --segments --program-headers   Display program headers
  -d --dynamic --dynamic-table      Display the dynamic section table
  -n --notes                        Display notes
  -V --version-info                 Display version sections
  -g --section-groups               Display section groups
  -I --histogram                    Display bucket list histogram for hash sections

  --elf-linker-options              Display the .linker-options section
  --elf-output-style=<value>        Specify ELF dump style: LLVM, GNU, JSON
  --gnu-hash-table                  Display the GNU hash table for dynamic symbols
  --hash-symbols                    Display the dynamic symbols derived from the hash section
  --hash-table                      Display .hash section
  --needed-libs                     Display the needed libraries
  --raw-relr                        Do not decode relocations in SHT_RELR section, display raw contents

Pass @FILE as argument to read options from FILE.
```

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