class npackd {
  Package {
    provider => npackd,
  }

  ### SHOULD FAIL ###

  # Both 'latest' and a specific version are specified. Either specific versions can be
  # specified, or latest can be specified, but not both. 
  package { 'net.winscp.WinSCP 5.1.5': }
  package { 'net.winscp.WinSCP':
    ensure => latest,
  }

  # Version in title and version from 'ensure' do not match. 
  package { 'net.winscp.WinSCP 5.1.4':
    ensure => '5.1.5',
  }

  # Repo is not a valid URL
  npackd_repo { 'badrepo': }

  ### SHOULD PASS ###

  # Should install firefox. 
  package { 'org.mozilla.Firefox': }

  # Should install the latest 64 bit python (and update when updates become available). 
  package { 'org.python.Python64':
    ensure  => latest,
  }

  # Should install Notepad++ 6.4.2
  package { 'net.sourceforge.NotepadPlusPlus 6.4.2': }
  
  # Should remove Notepad++ 6.3.2
  package { 'net.sourceforge.NotepadPlusPlus 6.3.2': 
    ensure => absent,
  }

  # Should add the new repo
  npackd_repo { 'http://example.com/repo.xml': }

}
