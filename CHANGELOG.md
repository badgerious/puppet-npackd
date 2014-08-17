### 1.1.2
- Updates for Puppet 3.7 / Ruby 64 bit

### v1.1.1
* Minor change to metadata.json

v1.1.0
------

- Compatible with npackd 1.18.7.
- `npackd_repo`s are now purgable.
- Npackd 1.18.7 now loads repos from a cache. Updates are made visible with
  `npackdcl detect`. Because of this, adding/removing an `npackd_repo` triggers a `detect`,
  and a manifest is included which periodically detects changes to the repos.
- `npackd_repo`s are located with the new `list-repo` command instead of searching the registry.

v1.0.0
======
- Refactored `npackd_pkg` into a normal `package` type. (I thought at first
  this wasn't going to work, but was wrong). 
