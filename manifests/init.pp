class npackd {
  # Periodically update the repos. Repos will be updated
  # automatically if a repo is added/removed.
  include npackd::detect

  # Install npackd, or, if already installed try to update.
  # (On older versions of puppet, updates must be done manually).
  if $puppetversion >= '3.4.0' {
    $ensure = '1.18.7'
  }
  else {
    $ensure = 'installed'
  }
  package { 'NpackdCL':
    ensure => $ensure,
    source => 'http://windows-package-manager.googlecode.com/files/NpackdCL-1.18.7.msi',
  }
}
