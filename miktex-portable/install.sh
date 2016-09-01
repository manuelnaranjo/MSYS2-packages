appdir=/usr/share/miktex-portable
innerdir=install/miktex/bin

pre_remove() {
  for file in $(find ${appdir}/${innerdir}/ -type f -name \*.exe ); do
    fname="$(basename ${file})"
    fname_noext="${fname%.*}"
    rm -f /usr/bin/${fname} /usr/bin/${fname_noext}
  done
}

pre_upgrade() {
  pre_remove;
}

post_install() {
  for file in $(find "${appdir}/${innerdir}/" -type f -name \*.exe); do
    fname="$(basename ${file})"
    MSYS='winsymlinks:lnk' ln -sf ${file} /usr/bin/${fname}
  done
}

post_upgrade() {
  post_install
}
