# Periodically update npackd repos
class npackd::detect {
  schedule { 'npackd-detect':
    period => weekly,
    range  => '12:00-16:00',
    repeat => 1,
  }

  exec { "npackdcl.exe detect":
    path     => $::path,
    schedule => 'npackd-detect',
    require  => Package['NpackdCL'],
  }
}
