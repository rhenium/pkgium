#!/bin/sh

###############################
# Build options
###############################
clang=1

_pwd=$(pwd)
export PATH="$_pwd/python-path:$_pwd/depot_tools:$PATH"

# Use Python 2.x
if [ ! -f "$_pwd/python-path/python" ]; then
  mkdir python-path
  ln -s /usr/bin/python2 python-path/python
fi


update() {
  cd "$_pwd"

  echo "preparing depot_tools...."
  [ ! -d depot_tools ] && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  git -C depot_tools pull origin master

  echo "obtaining source...."
  [ ! -d src ] && fetch blink
  cd src
  git pull origin master --no-edit || exit
  gclient sync --nohooks || exit

  ###############################
  ### configure chromium
  ###############################
  echo "configuring chromium...."

  export CFLAGS="-march=corei7-avx -mtune=corei7-avx -O2 -pipe"
  export CXXFLAGS="$CFLAGS"

  export GYP_DEFINES="
    clang=$clang
    clang_use_chrome_plugins=0
    fastbuild=1
    werror=
    linux_sandbox_path=/usr/lib/chromium-edge/chrome-sandbox
    usb_ids_path=/usr/share/hwdata/usb.ids
    release_extra_cflags='$CFLAGS'

    google_api_key='AIzaSyDwr302FpOSkGRpLlUpPThNTDPbXcIn_FM'
    google_default_client_id='413772536636.apps.googleusercontent.com'
    google_default_client_secret='0ZChLK6AxeA3Isu96MkwqDR4'

    ffmpeg_branding=Chrome
    proprietary_codecs=1

    enable_hidpi=0
    use_sysroot=0
    disable_nacl=1
  "

  cd "$_pwd/src"
  gclient runhooks || exit

cat <<EOF > out/Default/args.gn
enable_remoting = false
enable_widevine = true
ffmpeg_branding = "Chrome"
google_api_key = "AIzaSyDwr302FpOSkGRpLlUpPThNTDPbXcIn_FM"
google_default_client_id = "413772536636.apps.googleusercontent.com"
google_default_client_secret = "0ZChLK6AxeA3Isu96MkwqDR4"
is_debug = false
is_official_build = true
proprietary_codecs = true
use_sysroot = false
enable_nacl = false
remove_webcore_debug_symbols = true
symbol_level = 0
EOF

  gn gen out/Default || exit

  #python build/gyp_chromium.py
}

build() {
  echo "compiling...."

  # WORKAROUND
  # Bundled LLVM seems to need libtinfo.so.5
  ln -sf /usr/lib/libncursesw.so.6 "$_pwd/src/third_party/llvm-build/Release+Asserts/lib/libtinfo.so.5"

  cd "$_pwd/src"
  ninja -j4 -C out/Default chrome chrome_sandbox || exit
}

package() {
  echo "making package...."
  cd "$_pwd/makepkg"
  BUILD_ROOT="$_pwd" makepkg -f || exit
}

case "$1" in
  update) update ;;
  build) build ;;
  package) package ;;
  *) update && build && package ;;
esac
