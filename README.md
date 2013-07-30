Puppet Npackd
=============

This module implements a package provider for
[Npackd](http://code.google.com/p/windows-package-manager/), a package manager
for Windows.

See the [list of available packages](http://npackd.appspot.com/p). Each package listed there has an 'ID' 
field; this is the package name to use (note that NpackdCL is case sensitive). You can also use
`npackdcl.exe search` to find packages. The `()` enclosed name is the package ID. 

This module also includes a type (`npackd_repo`) for managing Npackd repositories. 

Install
=======

Install from puppet forge:

    puppet module install badgerious/npackd

Install from github (do this in your modulepath):

    git clone https://github.com/badgerious/puppet-npackd npackd

Examples
========

Managing Packages
----------------

```puppet

    # Install 7zip. This will install the latest version initially, and
    # apply no updates as long as any version is found on the system.
    package { 'org.7-zip.SevenZIP': 
      provider => npackd,
    }

    # Install latest WinSCP. This will always install the latest version
    # available in the repositories.
    package { 'net.winscp.WinSCP':
      ensure   => latest,
      provider => npackd,
    }

    # Install Firefox version 22. 
    package { 'org.mozilla.Firefox':
      ensure   => 22,
      provider => npackd,
    }

    # Install .NET runtime versions 4.5.50709.17929 and 4.0.30319.1. 
    # To install multiple versions of the same package, title the resource
    # "{package} {version}". This format cannot be used together with 
    # ambigiously versioned resources (e.g. ensure => latest) with the same
    # package name. 
    package { 'com.microsoft.DotNetRedistributable 4.0.30319.1':
      ensure   => installed,
      provider => npackd,
    }
    package { 'com.microsoft.DotNetRedistributable 4.5.50709.17929':
      ensure   => installed,
      provider => npackd,
    }

    # Remove ALL versions of PuTTY. If you specify a version, only that version will be removed. 
    # If there are multiple versions installed, one will be removed each puppet run (not ideal,
    # but will eventually get the job done). 
    package { 'uk.org.greenend.chiark.sgtatham.Putty':
      ensure   => absent,
      provider => npackd,
    }

```

Managing Repos
-------------

```puppet

    # Add a repo
    npackd_repo { 'https://windows-package-manager.googlecode.com/hg/repository/Rep.xml': }

    # Remove a repo
    npackd_repo { 'Badrepo':
      ensure => absent,
      repo   => 'https://windows-package-manager.googlecode.com/hg/repository/Rep.xml',
    }

```

Changes
=======

[Changelog](https://github.com/badgerious/puppet-npackd/blob/master/CHANGELOG.md)
