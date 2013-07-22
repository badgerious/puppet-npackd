Puppet Npackd
=============

This module implements a type/provider for
[Npackd](http://code.google.com/p/windows-package-manager/), a package manager
for Windows. The `npackd_pkg` type is similar to the built-in `package`,
except that versions are handled slightly differently (want to be able to
install and remove specific versions of packages, and have multiple versions
installed together; the built-in `package` cannot uninstall specific versions,
and requires the version to be part of the package name to install specific
versions). 

See the [list of available packages](http://npackd.appspot.com/p). Each package listed there has an 'ID' 
field; this is the package name to use (note that NpackdCL is case sensitive). You can also use
`npackdcl.exe search` to find packages. The `()` enclosed name is the package ID. 

This module also includes a type (`npackd_repo`) for managing Npackd repositories. 

Examples
========

Managing Packages
----------------

```puppet

    # Install 7zip. This will install the latest version initially, and
    # apply no updates as long as ANY version is found on the system, a la
    # the standard package type. 
    npackd_pkg { 'org.7-zip.SevenZIP': }

    # Install latest WinSCP. This will always install the latest version
    # available in the repositories (again, same as standard package). 
    npackd_pkg { 'net.winscp.WinSCP':
      ensure  => installed,
      version => latest,
    }

    # Install PuTTY 0.62. To install a specific version, title the resource
    # "{pkg_name} {version}". While it is possible to specify the version with
    # 'version => 0.62', the below format is necessary if you want to install multiple versions. 
    npackd_pkg { 'uk.org.greenend.chiark.sgtatham.Putty 0.62': }

    # Remove ALL versions of PuTTY. If you specify a version, only that version will be removed. 
    npackd_pkg { 'uk.org.greenend.chiark.sgtatham.Putty':
      ensure => absent,
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
