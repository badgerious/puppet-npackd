require 'puppetx/badgerious/npackd/providercommon'

Puppet::Type.type(:package).provide(:npackd) do
  desc "Provider for the Npackd package manager on Windows."

  include PuppetX::Badgerious::Npackd::ProviderCommon

  has_feature :installable, :uninstallable, :upgradable, :versionable

  # This will be an array of package names that couldn't be prefetched. The provider
  # instance will check this before doing anything, and error out if it finds
  # its package name in this list. 
  @failed_prefetch = []
  class << self
    attr_reader :failed_prefetch
  end

  # this method creates a table of the form:
  # { pkg_name => { some_version => pkg_a, nother_version => pkg_b } }
  # where 'pkg_a/pkg_b' may be a provider instance or a type instance. 
  # The table is used to match packages on the system with packages
  # specified in manifests. 
  def self.mk_pkg_table(pkgs)
    # Both provider instances and type instances will be inputs to this method,
    # but they don't handle getting properties the same way. 
    get = pkgs.first.class == Puppet::Type::Package ? :[] : :get
    table = Hash.new { {} }
    pkgs.each do |p|
      name = p.send(get, :description)
      version = p.send(get, :status)
      if table[name].any?
        table[name][version] = p
      else
        table[name] = { version => p }
      end
    end
    table
  end

  def self.prefetch(resources)
    resources.each_value do |resource|
      # TODO: allow short names?

      # If there is a both a package name and version in the resource title,
      # store just the package name in 'description'
      resource[:description] = resource[:name].split[0]

      # Version given in the name takes precedence over version given with 'ensure => {version}'.
      if status = resource[:name].split[1]
        resource[:status] = status
      end

      case resource[:ensure]
      when :installed, :present, :absent
        # undef means any version
        resource[:status] = :undef unless resource[:status]
      else
        if resource[:status] && resource[:status] != resource[:ensure]
          warning "#{self.resource_type.name.capitalize}[#{resource[:name]}]: Bad 'ensure' value of '#{resource[:ensure]}' (because version '#{resource[:status]}' is already specified in resource title)"
          @failed_prefetch << resource[:description]
        else
          resource[:status] = resource[:ensure]
        end
      end
    end

    resource_table = mk_pkg_table(resources.values)
    instance_table = mk_pkg_table(instances)

    resource_table.each do |pkg_name, version_hash|
      # If the user specifies exact versions, everything is ok; we can map
      # resources to provider instances without issue.
      # If the user specifies *one* package with either 'latest' version or
      # just 'installed', we'll map the latest versioned provider instance to
      # the resource and be ok. 
      # If, however, the user specifies two resources for the same package, one
      # with a specific version and one with 'latest' or 'installed', the
      # resources may map to the same provider instance. This is bad news, so
      # we'll mark down the package name in @failed_prefetch and skip all
      # resources with that package name. 
      version_list = version_hash.keys
      if (version_list.include?(:latest) || version_list.include?(:undef)) && version_list.count > 1
        @failed_prefetch << pkg_name
        warning "May not specify 'latest' or 'installed/present' together with specific versions for Npackd package '#{pkg_name}'."
        next
      end

      version_hash.each do |version, resource|
        if instance_table[pkg_name].any?
          case version
          when :latest, :undef
            max_version = instance_table[pkg_name].keys.max
            resource.provider = instance_table[pkg_name][max_version]
          else
            if prov = instance_table[pkg_name][version]
              resource.provider = prov
            else
              resource.provider = new(:ensure => :absent)
            end
          end
        else
          resource.provider = new(:ensure => :absent)
        end
      end
    end
  end

  def self.instances
    raw_output = npackdcl 'list', '--bare-format'
    packages = []
    raw_output.each_line do |line|
      line = line.split
      hash = {}

      # This will be "{package name} {package version}"
      hash[:name] = "#{line[0]} #{line[1]}"

      # using 'description' to store just package name
      hash[:description] = line[0]

      # using 'status' to store package version. In this case, it will be
      # the same as ensure, but for resources coming from the parser, it may 
      # be different (e.g. :present). Set 'status' here for uniformity. 
      hash[:status] = line[1] 
      hash[:ensure] = line[1]

      hash[:provider] = self
      packages << new(hash)
    end
    packages
  end

  # package type expects this method (normally inherited from package base class)
  def validate_source(value)
    true
  end

  def properties
    if self.class.failed_prefetch.include?(@resource[:description])
      fail "Skipping because prefetch for package '#{resource[:description]}' failed."
    end
    @property_hash
  end
 
  def install
    args = ['add', "--package=#{@resource[:description]}"]
    args << "--version=#{@resource[:status]}" unless [:undef, :latest].include?(@resource[:status])
    npackdcl(*args)
  end

  def uninstall
    npackdcl 'remove', "--package=#{@resource[:description]}", "--version=#{@property_hash[:status]}"
  end

  def update
    if @property_hash[:ensure] == :absent
      install
    else
      npackdcl 'update', "--package=#{@resource[:description]}"
    end
  end

  def latest
    unless @latest
      raw_output = npackdcl 'info', "--package=#{@resource[:description]}"
      @latest = raw_output.match(/^Versions: (.*)$/)[1].split(',')[-1].strip
    end
    @latest
  end
end
