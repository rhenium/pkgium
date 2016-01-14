#!/bin/sh

###############################
# Build options
###############################
clang=1

###############################
### set environment ###########
###############################
_pwd=$(pwd)
export PATH="$_pwd/python-path:$PATH"
export PATH="$_pwd/depot_tools:$PATH"

# Use Python 2.x
if [ ! -f "$_pwd/python-path/python" ]; then
  mkdir python-path
  ln -s /usr/bin/python2 python-path/python
fi
  

update() {
  ###############################
  ### fetch depot_tools
  ###############################
  echo "preparing depot_tools...."
  if [ -d depot_tools ]; then
    svn update depot_tools
  else
    svn checkout https://src.chromium.org/svn/trunk/tools/depot_tools
  fi
  
  ###############################
  ### fetch source
  ###############################
  echo "obtaining source...."
  if [ ! -d src ]; then
    fetch blink --nosvn=true
  fi
  cd "$_pwd/src"
  git pull upstream master --no-edit || exit
  gclient sync --nohooks
  
  ###############################
  ### configure chromium
  ###############################
  echo "configuring chromium...."
  # Will be used in PKGBUILD
  cd "$_pwd/depot_tools"
  svn info | grep 'Revision' | awk '{ print $2; }' > "$_pwd/BUILD_VERSION"
  
  #export CXX="clang++ -Qunused-arguments -D__extern_always_inline=inline"
  #if [ "$clang" = 1 ]; then
  #  export CC="clang -Qunused-arguments"
  #  export CXX="clang++ -Qunused-arguments"
  #fi
  
  export CFLAGS="-march=corei7-avx -mtune=corei7-avx -O2 -pipe"
  export CXXFLAGS="$CFLAGS"
  
    #host_clang=$clang
  export GYP_DEFINES="
    clang=$clang
    clang_use_chrome_plugins=0
    make_clang_dir=/usr
    fastbuild=1
    werror=
    linux_sandbox_path=/usr/lib/chromium-edge/chrome-sandbox
    linux_strip_binary=1
    linux_use_bundled_binutils=0
    linux_use_bundled_gold=0
    linux_use_gold_flags=1
    usb_ids_path=/usr/share/hwdata/usb.ids
    remove_webcore_debug_symbols=1
    release_extra_cflags='-march=corei7-avx -mtune=corei7-avx -O2 -pipe'
    logging_like_official_build=1
  
    google_api_key='AIzaSyDwr302FpOSkGRpLlUpPThNTDPbXcIn_FM'
    google_default_client_id='413772536636.apps.googleusercontent.com'
    google_default_client_secret='0ZChLK6AxeA3Isu96MkwqDR4'
  
    ffmpeg_branding=Chrome
    proprietary_codecs=1
  
    v8_use_snapshot=false
  
    enable_hidpi=0
    enable_widevine=1
  "
  
  cd "$_pwd/src"
  gclient runhooks || exit
}

build() {
  ###############################
  ### compile
  ###############################
  echo "compiling...."
  
  # WORKAROUND
  # Bundled LLVM seems to need libtinfo.so.5
  # ln -sf /usr/lib/libncurses.so.5 "$_pwd/src/third_party/llvm-build/Release+Asserts/lib/libtinfo.so.5"
  ## ann
  # ln -sf /usr/lib/libstdc++.so.6 "$_pwd/src/third_party/llvm-build/Release+Asserts/lib/libstdc++.so.6"
  
  cd "$_pwd/src"
  ninja -j4 -C out/Release chrome chrome_sandbox chromedriver || exit
}

package() {
  ###############################
  ### packaging
  ###############################
  echo "making package...."
  cd "$_pwd/makepkg"
  BUILD_ROOT="$_pwd" makepkg -f || exit
  
  #sudo -uadmin cp chromium-edge-$(cat "$_pwd/BUILD_VERSION")-1-x86_64.pkg.tar.xz /nas/build/chromium-edge/
}

case "$1" in
  update ) update ;;
  build ) build ;;
  package ) package;;
  * ) update && build && package ;;
esac
