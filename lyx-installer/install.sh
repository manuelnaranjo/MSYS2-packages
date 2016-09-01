lyxdir=/usr/share/lyx-installer
miktex=/usr/share/miktex-portable/install/miktex/bin

pre_remove() {
  for file in $(find ${lyxdir}/bin -type f -name \*.exe ); do
    fname="$(basename ${file})"
    fname_noext="${fname%.*}"
    rm -f /usr/bin/${fname} /usr/bin/${fname_noext}
  done
  rm ${lyxdir}/Resources/lyxrc.dist
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

  echo "\path_prefix \"$(cygpath -a -m ${miktex})\"" > ${lyxdir}/Resources/lyxrc.dist
  python ${lyxdir}/postinstall.py
}

post_upgrade() {
  post_install
}
