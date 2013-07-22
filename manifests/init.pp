class npackd {
  # install npackd
  package { 'NpackdCL':
    ensure => installed,
    source => 'http://windows-package-manager.googlecode.com/files/NpackdCL-1.17.9.msi',
  }
}
