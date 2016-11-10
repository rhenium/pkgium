#!/bin/sh
set -e

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
  if [ ! -d src ]; then
    fetch chromium
  fi
  cd src
  git pull origin master --no-edit
  gclient sync --nohooks

  echo "configuring chromium...."

  cd "$_pwd/src"
  gclient runhooks

  gn gen out/Default

cat <<EOF > out/Default/args.gn
is_clang=false
clang_use_chrome_plugins=false

enable_remoting = false
enable_hangout_services_extension = true
enable_widevine = true
enable_nacl = false
enable_nacl_nonsfi = false
google_api_key = "AIzaSyDwr302FpOSkGRpLlUpPThNTDPbXcIn_FM"
google_default_client_id = "413772536636.apps.googleusercontent.com"
google_default_client_secret = "0ZChLK6AxeA3Isu96MkwqDR4"
ffmpeg_branding = "Chrome"
# is_official_build = true
fieldtrial_testing_like_official_build = true
proprietary_codecs = true
use_sysroot = false
linux_use_bundled_binutils = false
is_debug = false
remove_webcore_debug_symbols = true
symbol_level = 0
treat_warnings_as_errors = false
EOF

  gn gen out/Default
}

build() {
  echo "compiling...."
  cd "$_pwd/src"

  ninja -j4 -C out/Default chrome chrome_sandbox
}

package() {
  echo "making package...."
  cd "$_pwd/makepkg"

  BUILD_ROOT="$_pwd" makepkg -f
}

case "$1" in
  update)
    update
    ;;
  build)
    build
    ;;
  package)
    package
    ;;
  *)
    update && build && package
    ;;
esac
