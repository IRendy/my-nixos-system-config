# baidupcs.yazi

在 yazi 里用 [BaiduPCS-Go](https://github.com/qjfoidnh/BaiduPCS-Go) 操作百度网盘：浏览、上传、下载、增删改、分享、账号登录。

## 安装

NixOS（本仓库）：插件已在 `users/irendy/configuration.nix` 的 `programs.yazi.plugins` 里注册，
键位在 `pkgs/yazi/settings.nix`，`nixos-rebuild switch` 后生效。

其他环境：把 `baidu.yazi` 整个目录放到 `~/.config/yazi/plugins/`（或 `$YAZI_CONFIG_HOME/plugins/`），
并自行把键位写进 `keymap.toml`。

## 键位（已在 settings.nix 里绑定）

| 键 | 作用 |
| --- | --- |
| `B b` | 打开网盘面板（浏览/管理） |
| `B u` | 把 yazi 里选中（或悬停）的本地文件上传到网盘 |
| `B d` | 输入网盘路径，下载到 yazi 当前目录 |
| `B a` | 账号子菜单 |

## 面板键位（`B b` 打开）

键位尽量与 yazi 原生 file manager 一致（括号里是对应的原生动作）：

| 键 | 作用 | 原生对照 |
| --- | --- | --- |
| `j` `k` `<Up>` `<Down>` | 上下移动 | `arrow` |
| `g` `G` | 跳到首 / 尾 | `arrow top/bot` |
| `l` `<Right>` | 进入目录（文件上无动作，同原生） | `enter` |
| `<Enter>` `o` | 下载选中项 / 悬停项到 yazi 当前目录 | `open` |
| `h` `<Left>` `<Backspace>` | 回到上级目录 | `leave` |
| `<Space>` | 选择并**下移一格**（左侧黄条），便于连续多选 | `toggle; arrow 1` |
| `<C-a>` / `<C-r>` | 全选 / 反选当前目录（选择可跨目录累积） | `toggle_all` |
| `y` | 复制（左侧**绿**条）；按后自动清空选择 | `yank` |
| `x` | 剪切（左侧**红**条）；按后自动清空选择 | `yank --cut` |
| `p` / `P` | 粘贴到这里（复制 / 移动），有确认弹窗 | `paste` / `paste --force` |
| `Y` `X` | 清除 yank/cut 状态 | `unyank` |
| `d` `D` | 删除选中项（有确认，进网盘回收站） | `remove` |
| `a` | 新建：以 `/` 结尾建目录 | `create` |
| `r` | 重命名（预填原名） | `rename` |
| `s` | 搜索当前目录（block 模式） | `search` |
| `:` | 跳转到指定网盘目录 | — |
| `u` | 把 yazi 里选中的本地文件上传到面板当前目录 | — |
| `t` | 树状列出当前目录（block 模式） | — |
| `i` | 网盘配额 + 当前账号 | — |
| `c` / `C` | 分享链接 / 直链（自动复制到剪贴板） | — |
| `R` | 重新加载当前目录 | — |
| `~` | 键位提示 | `help` |
| `q` / `Esc` / `<C-c>` | 关闭面板 | `quit` |

和原生一致的状态机：`<Space>` 选中的条目是**黄条**，按 `y`/`x` 后选择集被清空、变成**绿条/红条**
（原生 `yank` 也会 `escape_select`）；删除、移动完成后对应的路径会从选择集里剔除；面板自己重开后
选择集和 yank 状态都会保留（和 yazi 跨操作保留选择一样）。

输入框（`a` 新建、`u` 上传目标、`:` 跳转等）会**预填**上次用过的路径，直接输入会追加；
要整体替换先按 `Ctrl-U` 清空。

配色直接用 yazi 主题：选择标记用 `th.mgr.marker_selected`（黄）、复制用 `marker_copied`（绿）、
剪切用 `marker_cut`（红）、标记符号用 `mgr.marker_symbol`，悬停行用 `th.indicator.current`（反显），
边框用 `th.mgr.border_style`。换 flavor / theme 面板会跟着变。

两点与原生不同，需要注意：

- `a` 建**文件**：网盘没有"创建空文件"的接口，所以输入不带 `/` 的名字会提示无法创建
  （原生 yazi 会用 `filename` 建空文件）。
- 关闭面板后如果立刻再按一次 `q`，第二下会退出 yazi（内建的 mount 插件也是这个行为）。

上传 / 下载会切到 baidupcs-go 自己的界面（block 模式），能看到原生进度条、可以 `Ctrl-C` 中断，
结束后按回车回到 yazi。其余操作在后台跑，用 yazi 的通知汇报结果。

## 直接调用

也可以自己绑键或从命令模式调用 `plugin baidu -- <子命令>`：

```
panel [远端目录]            打开面板
upload [远端目录]           上传 yazi 选中/悬停的本地文件
download [远端路径...]      下载到 yazi 当前目录
ls [远端目录]               block 模式跑 ls -l
tree [远端目录]             block 模式跑 tree
mkdir <远端路径>            新建目录
rm <远端路径...>            删除（有确认）
mv <源> [目标]              移动 / 重命名
cp <源...> <目标目录>       拷贝（面板的粘贴走这个）
share <远端路径>            分享链接 → 剪贴板
locate <远端路径>           直链 → 剪贴板
search [远端目录]           按文件名搜索（block 模式）
quota / who / loglist       配额 / 当前账号 / 账号列表
su [uid]                    切换账号（block 模式，交回 baidupcs-go 交互）
logout                      退出登录（有确认）
account                     账号子菜单（等价于 B a）
login_cookies / login_bduss 用 Cookies / BDUSS+STOKEN 登录
```

## 账号登录

`B a` 打开子菜单：

- `c` Cookies 登录：`baidupcs-go login -cookies=...`
- `b` BDUSS + STOKEN 登录（STOKEN 可留空，但转存功能需要它）
- `s` 切换账号、`o` 退出、`w` 当前账号、`l` 账号列表

凭证请自行从浏览器 Cookie 里取，交给 BaiduPCS-Go 保存。**注意**：

- BaiduPCS-Go 把 BDUSS/STOKEN/Cookies 明文存在 `~/.config/BaiduPCS-Go/pcs_config.json`（权限 0600）。
- 本插件**不**把任何凭证写进自己的状态文件；登录参数直接作为 argv 传给 `baidupcs-go`（不经过 shell）。
- 面板顶部的账号名是直接读上面那个 JSON 得到的（`baidu_active_uid`），**不产生任何 API 请求**。

## 状态与环境变量

- 状态文件：`$XDG_STATE_HOME/baidu.yazi/state.json`（默认 `~/.local/state/baidu.yazi/state.json`），
  只记两个路径：`remote_dir`（面板/下载的默认目录）、`upload_dir`（上传目标默认值）。
  不写这里的原因：NixOS 的 `programs.yazi` 把 `YAZI_CONFIG_HOME` 指向只读的 nix store 路径。
- `BAIDU_YAZI_BIN`：覆盖 `baidupcs-go` 可执行文件位置（默认走 PATH）。
- `BAIDU_YAZI_TRACE`：设为文件路径后，插件会把关键步骤追加写入该文件（用来在没有日志的环境里排错）。

## 排错

**插件的报错不会弹通知**——没有 `--- @sync entry` 标注的插件在 yazi 里是异步任务，
失败只体现在任务管理器里：在 yazi 里按 `w`，选中失败的任务按回车看错误栈。

常见问题：

- 面板打开后是空列表并显示 `Empty or unreadable directory`：远端目录不存在或没有权限。
- 下载/上传没反应：看 `w` 任务管理器；也确认 `baidupcs-go who` 还是登录状态。

## 开发循环（不用 nixos-rebuild）

flake 只能看到 git 已跟踪的文件，新文件先 `git add -N`：

```bash
cd /home/irendy/Documents/nixos
git add -N pkgs/yazi/plugins/baidu.yazi
nix build --impure --no-link --out-link /tmp/yazi-dev --expr '
  let f = builtins.getFlake "/home/irendy/Documents/nixos";
      c = f.nixosConfigurations.nixos.config;
  in c.programs.yazi.package.override { inherit (c.programs.yazi) settings initLua plugins flavors; }'
/tmp/yazi-dev/bin/yazi        # 与系统一致的 wrapper，秒级重建
```

验证语法用 Luau（yazi 的 Lua 运行时是 Luau，不是标准 Lua 5.4）：

```bash
nix build --impure --no-link --print-out-paths --expr \
  '(builtins.getFlake "/home/irendy/Documents/nixos").inputs.nixpkgs.legacyPackages.x86_64-linux.luau'
```

## 实现要点

- `main.lua` 只做子命令派发，`actions.lua` 是各操作的实现，`panel.lua` 是模态面板，`util.lua` 是基础设施。
- 走 `ya.emit("shell", {..., block = true})` 的操作会把命令行拼成字符串，路径统一用单引号转义。
- 其余操作走 `Command("baidupcs-go"):arg(...)`（不经 shell），失败时把 stderr 显示在通知里。
- `ya.sync` 包装的函数**不要自己传 `self`**：yazi 会自动把插件表作为第一个参数注入；
  显式传 `self` 会让它被序列化（里面有 channel/userdata），直接报 "unsupported userdata"。
- yazi 同时只能有一个提示层。面板的按键循环会在需要 `ya.input` / `ya.confirm` / 终端之前退出，
  操作执行完再重新打开面板（见 `panel.lua` 的 `entry`）。
- **按键捕获不能有空窗**：`ya.which` 只在它自己等待按键时占据 Which 层；一旦返回、而插件去做
  耗时的事（比如联网 `ls`），yazi 就把按键交回 manager 键位表，面板里按的 `h`/`l`/`q` 会漏到
  主界面（内建 mount 插件用本地 `lsblk`，几十毫秒所以不明显）。所以面板把网络加载放进独立的
  loader 协程，按键循环只往 channel 里塞请求、立刻回到 `ya.which`（`loader`/`keys` 两个协程由
  `ya.join` 并发跑）。
- 选择 / 复制的状态用**网盘绝对路径**记录（和原生 yazi 记录 URL 一样），不是文件名，
  否则换目录后粘贴会拼错路径。
- 拼命令行时注意 Lua 的坑：`{ "cmd", table.unpack(list), dest }` 里 `table.unpack`
  **不在末尾就只展开第一个值**——多选上传/粘贴曾经因此只传了第一个文件。要么把 unpack 放最后，
  要么用循环逐个 append（现在就是这么写的）。
