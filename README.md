# rhenium/pkgbuilds
わたしの使っている Arch Linux 向けの PKGBUILD です

dependencies あまりまじめに書いていないので、もし不足があれば自分でなんとかしてください。

## aribb24
[aribb24](https://github.com/nkoriyama/aribb24) の PKGBUILD
最新の VLC（Git から）で地デジ放送の字幕を表示するのに必要

## aribb25
[aribb25](http://git.videolan.org/?p=aribb25.git;a=summary) の PKGBUILD
VLC で MULTI2 復号されていない ts ファイルを再生するのに必要

## vlc-edge
`-edge` のサフィックス付きで git master の VLC media player をインストールするための PKGBUILD

## chromium-edge
git master の Chromium と PPAPI Flash をまとめたパッケージを作るためのスクリプト

## pacman-mirrorlist-dummy
provides=(pacman-mirrorlist) なカスタムミラーリスト（日本のミラーサーバーのみ）

## libskk / fcitx-skk
Fcitx から SKK を使うためのもの。https://github.com/rhenium 以下にあるわたしの fork をインストールするための PKGBUILD
（カスタマイズ無しのものは Arch Linux の community リポジトリにあります）
