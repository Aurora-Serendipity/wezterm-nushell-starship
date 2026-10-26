# 终端艺术与 WezTerm 玩法

> 返回：[README](../README.md) · 相关：[使用手册](usage.md) · [定制指南](customization.md)

本文记录本仓库配套的终端艺术工具（chafa / Fastfetch / figlet / cmatrix / timg 等）的安装命令、
在 Windows 与 WSL 中的分工，以及 `config.nu` 里的 `img` / `art` / `banner` 三个快捷命令。

灵感与工具清单来自：[《终端 ASCII 艺术 · 完整手册》](https://mp.weixin.qq.com/s/A4uJLqTB5VNw_FxqcfZ4hw)。

## 1. 三个快捷命令（默认 Nushell）

已在 `config/nushell/config.nu` 第 8 节定义：

| 命令         | 作用                                                          | 依赖               |
| ------------ | ------------------------------------------------------------- | ------------------ |
| `img <图片>` | WezTerm 内用内置图像协议显示原图；其他终端回退到 chafa 字符画 | `wezterm`、`chafa` |
| `art <图片>` | 用 chafa 生成彩色字符/方块画                                  | `chafa`            |
| `banner`     | 系统信息（Fastfetch），支持透传 fastfetch 参数                | `fastfetch`        |

示例（注意 Windows 路径用**单引号**，避免 Nushell 把 `\U` 当转义）：

```nu
img 'C:\Users\Aurora-Serendipity\wezterm-nushell-starship\docs\images\wezterm-window.png'
art 'C:\Users\Aurora-Serendipity\wezterm-nushell-starship\docs\images\wezterm-window.png'
banner
banner --logo none
```

- `img` 在 WezTerm 内实际调用 `wezterm imgcat`，显示高清原图；在 Windows Terminal / SSH 等环境
  会自动退回 chafa 字符画。
- `banner` 会覆盖 Nushell 内置的 `banner` 命令（内置命令只显示 Nushell 启动信息）；
  不想要时删除 `config.nu` 第 8 节即可恢复。
- `banner` 不放入启动流程；需要时手动运行，避免拖慢每个新标签。

## 2. 字符画 vs 原生图像

| 方式         | 命令                     | 优点                   | 缺点                                        |
| ------------ | ------------------------ | ---------------------- | ------------------------------------------- |
| 原生图像协议 | `img` / `wezterm imgcat` | 高清、真彩、快         | 不能复制、不一定进 scrollback、依赖终端支持 |
| 字符/方块画  | `art` / chafa            | 纯文本、可复制、可保存 | 分辨率受字符网格限制                        |
| ANSI Art     | 直接 `cat` 或专用编辑器  | 复古 BBS 风格          | 需要自己创作                                |

WezTerm 支持 iTerm2 图像协议（`wezterm imgcat` 已内置可用）；较新的 WezTerm 文档还列出 Kitty / Sixel
图形协议，`timg` 等工具可以尝试 `-pk`（Kitty）或 `-ps`（Sixel）。

## 3. 本机安装了什么

### 3.1 Windows / 默认 Nushell（winget / pip）

| 工具                  | 命令                    | 版本（实测） |
| --------------------- | ----------------------- | ------------ |
| chafa                 | `chafa`                 | 1.18.3       |
| ascii-image-converter | `ascii-image-converter` | 1.13.1       |
| Fastfetch             | `fastfetch`             | 2.70.0       |
| ImageMagick           | `magick`                | 7.1.2-34     |
| pyfiglet              | `python -m pyfiglet`    | 1.0.4        |
| Pillow                | Python 包               | 12.2.0       |
| OpenCV                | 用 `py -3.13` 导入      | 5.0.0        |
| sl                    | `sl`（已加入 PATH）     | 6.1.5        |
| WezTerm imgcat        | `wezterm imgcat`        | 随 WezTerm   |

### 3.2 Ubuntu-24.04（WSL）

`jp2a`、`figlet`、`toilet`、`showfigfonts`、`cmatrix`、`cbonsai`、`asciiquarium`、`nyancat`、
`img2txt`（caca-utils）、`libaa-bin`、`timg`、`pfetch`、`pipes.sh`、`hyfetch`。

## 4. 复现安装命令

### 4.1 Windows 原生

```powershell
winget install --id hpjansson.Chafa --silent
winget install --id TheZoraiz.ascii-image-converter --silent
winget install --id Fastfetch-cli.Fastfetch --silent
winget install --id ScaryRawr.SL --silent
winget install --id ImageMagick.ImageMagick --silent

python -m pip install pyfiglet pillow
py -3.13 -m pip install opencv-python   # 64 位 Python；默认 python 可能是 32 位

# sl 由 winget 安装到 C:\Program Files\sl\bin，需要加入用户 PATH
$slDir = 'C:\Program Files\sl\bin'
$userPath = [Environment]::GetEnvironmentVariable('Path','User')
if (($userPath -split ';') -notcontains $slDir) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$slDir", 'User')
}
```

### 4.2 Ubuntu-24.04（WSL）

```powershell
wsl -d Ubuntu-24.04 -u root -- bash -lc "apt-get update"
wsl -d Ubuntu-24.04 -u root -- bash -lc "DEBIAN_FRONTEND=noninteractive apt-get install -y jp2a figlet toilet cbonsai nyancat cmatrix timg caca-utils libaa-bin hyfetch curl"
```

`asciiquarium` 不在 Ubuntu 仓库里，需要脚本 + CPAN 模块：

```bash
sudo apt install -y cpanminus libcurses-perl build-essential
sudo cpanm --notest Term::Animation
sudo curl -fsSL https://raw.githubusercontent.com/cmatsuoka/asciiquarium/master/asciiquarium \
  -o /usr/local/bin/asciiquarium
sudo chmod +x /usr/local/bin/asciiquarium
```

`pfetch` / `pipes.sh` 是脚本，安装到 `/usr/local/bin`：

```bash
sudo curl -fsSL https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch -o /usr/local/bin/pfetch
sudo curl -fsSL https://raw.githubusercontent.com/pipeseroni/pipes.sh/master/pipes.sh -o /usr/local/bin/pipes.sh
sudo chmod +x /usr/local/bin/pfetch /usr/local/bin/pipes.sh
```

## 5. 试玩命令

### 5.1 Windows / 默认 Nushell

```nu
# 图片
img 'C:\path\to\image.png'
art 'C:\path\to\image.png'
wezterm imgcat 'C:\path\to\image.png' --width 80
ascii-image-converter -c --width 60 'C:\path\to\image.png'

# 系统信息 / 艺术字 / 动画
banner
python -m pyfiglet HELLO
sl
```

### 5.2 Ubuntu-24.04（在 WezTerm 中按 `Ctrl+Shift+1` 进入）

```bash
IMG=/mnt/c/Users/Aurora-Serendipity/wezterm-nushell-starship/docs/images/wezterm-window.png

jp2a --width=80 "$IMG"
img2txt --width=80 --height=40 "$IMG"
timg -pk "$IMG"          # Kitty；-ps 为 Sixel；不生效时直接 timg "$IMG"
timg "$IMG"

figlet HELLO
toilet -f big -F metal HELLO
showfigfonts

cmatrix
cbonsai
asciiquarium
nyancat
pfetch
pipes.sh
hyfetch
```

> `cbonsai` 安装在 `/usr/games/cbonsai`，WSL 的登录 shell PATH 已包含 `/usr/games`，直接输入即可。

## 6. 注意事项

1. **背景透明度**：本配置有背景图 + `window_background_opacity = 0.7`，字符画的暗部可能与壁纸混在一起；
   追求干净效果时可临时把透明度调成 1.0，或换一个无背景的标签页。
2. **图片能否复制**：`img` / `wezterm imgcat` 是原生图像，通常不能复制或进入 scrollback；
   需要可复制的图就用 `art` / chafa。
3. **Python 版本**：默认 `python` 是 32 位 3.13，OpenCV 装在 64 位 Python，使用 `py -3.13` 调用；
   `pyfiglet` 普通 `python -m pyfiglet` 即可。
4. **WSL 路径**：WSL 里访问 Windows 文件要用 `/mnt/c/...`；直接 `cd /mnt/c/Users/...`。
5. **timg / 协议**：`timg -pk`/`-ps` 依赖终端支持；WezTerm 支持 iTerm2/Kitty/Sixel 时可用，
   否则用默认 Unicode 半块模式。
6. **banner 覆盖**：`banner` 覆盖了 Nushell 内置命令，删除第 8 节即可恢复原版。
7. **不要塞进 Prompt/启动**：Fastfetch、动画都不要放进 Starship 提示符或每次启动流程，
   否则会拖慢每个新标签。

## 7. 未安装 / 不推荐

| 内容                                   | 原因                                                         |
| -------------------------------------- | ------------------------------------------------------------ |
| Neofetch                               | 已归档，使用 Fastfetch 代替                                  |
| screenfetch                            | 老、维护差                                                   |
| hollywood                              | 噪音大、资源占用高，纯演示                                   |
| ffmpeg + chafa 视频                    | 逐帧转换慢、抖动明显，尝鲜即可                               |
| PabloDraw / Moebius / ASCII Art Studio | 桌面绘图软件，不属于终端内工具；想创作 ANSI Art 时再单独使用 |
| asciiart.eu / 16colors.jp 等           | 在线资源，浏览器访问即可，无需安装                           |

## 8. 还可以做什么

- 给 `img` 增加 `--width` 参数（现在固定由 `wezterm imgcat` 自动选尺寸）；
- 为 WSL 里的 `jp2a`/`img2txt`/`timg` 写 bash/PowerShell 包装函数；
- 用 `timg -pk` / `-ps` 测试 WezTerm 的 Kitty/Sixel 输出并截图；
- 用 Python + OpenCV 复现文章里的"读图 → 缩放 → 亮度映射"算法；
- 把常用命令收进一个 `art-help` 帮助函数，减少记忆成本。
## 9. 资源网站

文章里提到的在线资源，浏览器打开即可，无需安装：

- [asciiart.eu](https://asciiart.eu)：最大的 ASCII 艺术库之一
- [16colors.jp](https://16colors.jp)：ANSI Art 博物馆
- [ascii.co.uk](https://ascii.co.uk)：分类齐全
- [textart.io](https://textart.io)：在线生成与分享
- Reddit：[r/ASCIIArt](https://www.reddit.com/r/ASCIIArt/)、[r/ANSIart](https://www.reddit.com/r/ANSIart/)
