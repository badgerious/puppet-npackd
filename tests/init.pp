class npackd {
  ### SHOULD FAIL ###

  # Both 'latest' and a specific version are specified. Either specific versions can be
  # specified, or latest can be specified, but not both. 
  npackd_pkg { 'net.winscp.WinSCP 5.1.5': }
  npackd_pkg { 'net.winscp.WinSCP':
    version => latest,
  }

  # Repo is not a valid URL
  npackd_repo { 'badrepo': }

  ### SHOULD PASS ###

  # Should install firefox. 
  npackd_pkg { 'org.mozilla.Firefox': }

  # Should install the latest 64 bit python (and update when updates become available). 
  npackd_pkg { 'org.python.Python64':
    ensure  => installed,
    version => latest,
  }

  # Should install Notepad++ 6.4.2
  npackd_pkg { 'net.sourceforge.NotepadPlusPlus 6.4.2': }
  
  # Should remove Notepad++ 6.3.2
  npackd_pkg { 'net.sourceforge.NotepadPlusPlus 6.3.2': 
    ensure => absent,
  }

  # Should add the new repo
  npackd_repo { 'http://example.com/repo.xml': }

}
