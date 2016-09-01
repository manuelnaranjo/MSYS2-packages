lyxdir=/usr/share/lyx-installer

pre_remove() {
  for file in $(find ${lyxdir}/bin -type f -name \*.exe ); do
    fname="$(basename ${file})"
    fname_noext="${fname%.*}"
    rm -f /usr/bin/${fname} /usr/bin/${fname_noext}
  done
  rm -rf ${lyxdir}/Resources/lyx2lyx
}

pre_upgrade() {
  pre_remove;
}

post_install() {
  for file in $(find "${lyxdir}/bin" -type f -name \*.exe); do
    fname="$(basename ${file})"
    MSYS='winsymlinks:lnk' ln -sf ${file} /usr/bin/${fname}
  done
  python ${lyxdir}/postinstall.py
}

post_upgrade() {
  post_install
}
