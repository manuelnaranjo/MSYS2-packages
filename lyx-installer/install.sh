lyxdir=/usr/share/lyx-installer

post_install() {
  python ${lyxdir}/postinstall.py
}

post_upgrade() {
  post_install
}
