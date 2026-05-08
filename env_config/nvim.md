# nvim 配置

1. 安装 lazyvim 配置

```
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

2. 修改配置

```
-- ~/.config/nvim/lua/config/options.lua

-- 让拼写检查忽略驼峰命名（CamelCase）
vim.opt.spelloptions:append("camel")
-- cjk 代表中日韩字符，设置后 Neovim 会忽略这些区域的字符检查。
vim.opt.spelllang = { "en", "cjk" }
```
