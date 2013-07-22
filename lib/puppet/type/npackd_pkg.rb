Puppet::Type.newtype(:npackd_pkg) do
  desc "Npackd packages."

  # An explanation of 'name', 'pkg_name', and 'title_patterns' in this Type:
  #
  # 'name' must be unique across versions of the same package for provider
  # prefetch to work (the parameter that is passed to prefetch is a hash of the
  # form { name => resource }, so 'name' needs to be of the form "{pkg} {version}".
  # (we can't use title_patterns here to just split into name and version,
  # since this would still produce resources with identical names; prefetch
  # ignores other namevars and uses exclusively 'name').  The :pkg_name param
  # is just "{pkg}". If the user doesn't specify multiple versions, :pkg_name
  # and :name may be the same thing.

  self::IDENT = proc { |x| x }

  def self.title_patterns
    [[/((\S+) (\S+))/, [[:name, self::IDENT], [:pkg_name, self::IDENT], [:version, self::IDENT]]],
     [/((\S+))/, [[:name, self::IDENT], [:pkg_name, self::IDENT]]]]
  end

  ensurable do
    newvalue(:present) { provider.install }
    newvalue(:absent) { provider.uninstall }
    defaultto(:present)
    aliasvalue(:installed, :present)
  end

  newparam(:pkg_name) do
    desc "The name of the package."
    isnamevar
  end

  newparam(:name) do
    desc "The name of the package plus its version. 'name' is unique across versions, while 'pkg_name' is not."
  end

  newparam(:version) do
    desc "The version of the package."
    isnamevar
    defaultto(:undef)
    munge do |v|
      if v == 'latest'
        :latest
      else
        v
      end
    end
  end
end
