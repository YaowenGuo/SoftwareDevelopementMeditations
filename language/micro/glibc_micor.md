# Glibc 源码 —— 宏

versioned_symbol 用于定义函数版本兼容。如果是共享库，需要添加版本

```C
/* versioned_symbol (LIB, LOCAL, SYMBOL, VERSION) emits a definition
   of SYMBOL with a default (@@) VERSION appropriate for LIB.  (The
   actually emitted symbol version is adjusted according to the
   baseline symbol version for LIB.)  The address of the symbol is
   taken from LOCAL.  Properties of LOCAL are copied to the exported
   symbol.  In particular, LOCAL itself should be global.  It is
   unspecified whether SYMBOL@VERSION is associated with LOCAL, or if
   an intermediate alias is created.  If LOCAL and SYMBOL are
   distinct, and LOCAL is also intended for export, its version should
   be specified explicitly with versioned_symbol, too.  */
# define versioned_symbol(lib, local, symbol, version) \
  versioned_symbol_1 (lib, local, symbol, version)
# define versioned_symbol_1(lib, local, symbol, version) \
  versioned_symbol_2 (local, symbol, VERSION_##lib##_##version)
# define versioned_symbol_2(local, symbol, name) \
  default_symbol_version (local, symbol, name)
```

如果非共享库，则将定义设置为全局的。

```
/* No versions to worry about, just make this the global definition.  */
# define versioned_symbol(lib, local, symbol, version) \
  weak_alias (local, symbol)
```