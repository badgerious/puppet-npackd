class npackd {
  # Uncomment to periodically update the repos. (Repos will be updated
  # automatically any time a repo is added/removed, but otherwise
  # will not update themselves).
  # Note that, if you enable this and are installing npackd from
  # scratch, it will fail on the first run because npackd is
  # not yet in %PATH%. This is safe to ignore. You can also
  # hard code the path to npackdcl.exe in to detect.pp if you want to avoid this.
  #
  # include npackd::detect

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
