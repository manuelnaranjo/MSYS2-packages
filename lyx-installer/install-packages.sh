post_install() {
  # update the installed b
  mpm --update-db
  initexmf --verbose --mklinks --mkmaps --update-fndb
}

post_remove() {
  post_install
}

post_upgrade() {
  post_install
}

post_upgrade() {
  post_install
}
