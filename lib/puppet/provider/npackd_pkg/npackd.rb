require 'puppetx/badgerious/npackd/providercommon'

Puppet::Type.type(:npackd_pkg).provide(:npackd) do
  desc "Provider for the Npackd package manager on Windows."

  include PuppetX::Badgerious::Npackd::ProviderCommon

  # resources will normally run even if prefetch fails. Don't want that to happen here,
  # so we'll have the instances check this before running.
  @prefetch_ok = true
  class << self
    attr_reader :prefetch_ok
  end

  def self.mk_pkg_table(pkgs)
    # Providers and types don't access properties the same way
    get = pkgs.first.class == Puppet::Type::Npackd_pkg ? :[] : :get
    table = Hash.new { {} }
    pkgs.each do |p|
      if table[p.send(get, :pkg_name)].any?
        table[p.send(get, :pkg_name)][p.send(get, :version)] = p
      else
        table[p.send(get, :pkg_name)] = { p.send(get, :version) => p }
      end
    end
    table
  end

  def self.prefetch(resources)
    resource_table = mk_pkg_table(resources.values)

    resource_table.each do |pkg_name, version_hash|
      version_list = version_hash.keys
      if (version_list.include?(:latest) || version_list.include?(:undef)) && version_list.count > 1
        @prefetch_ok = false
        fail "May not specify 'latest' or 'undef' together with other versions for Npackd package '#{pkg_name}'."
      end
    end

    instance_table = mk_pkg_table(instances)

    instance_table.each do |pkg_name, versions_hash|
      if resource_table[pkg_name].any?
        case resource_table[pkg_name].keys.first
        when v = :latest, v = :undef
          resource_table[pkg_name][v].provider = versions_hash[versions_hash.keys.max]
        else
          resource_table[pkg_name].each do |version, resource|
            resource.provider = versions_hash[version] if versions_hash[version]
          end
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
      hash[:pkg_name] = line[0]
      hash[:ensure] = :present
      hash[:version] = line[1]
      hash[:display_name] = line[2..-1].join(' ')
      hash[:provider] = self
      packages << new(hash)
    end
    packages
  end

  def exists?
    self.class.prefetch_ok or fail "Skipping because prefetch failed."
    if @resource[:version] != :undef
      @property_hash[:version] && @property_hash[:version].include?(@resource[:version] == :latest ? latest : @resource[:version])
    else
      @property_hash[:version]
    end
  end
 
  def install
    if @resource[:version] == :latest && @property_hash[:version]
      notice "Updating '#{@resource[:pkg_name]}' from version '#{@property_hash[:version]}' to '#{latest}'"
      npackdcl 'update', "--package=#{@resource[:pkg_name]}"
    else
      args = ['add', "--package=#{@resource[:pkg_name]}"]
      args << "--version=#{@resource[:version]}" unless [:undef, :latest].include?(@resource[:version])
      debug "Installing '#{@resource[:pkg_name]}'"
      npackdcl(*args)
    end
  end

  def uninstall
    if @resource[:version] != :undef
      versions = [@resource[:version] == :latest ? latest : @resource[:version]]
    else
      # no version supplied means remove ALL versions
      versions = @property_hash[:versions]
    end
    versions.each do |version|
      debug "Removing '#{@resource[:pkg_name]}' version #{version}"
      npackdcl 'remove', "--package=#{@resource[:pkg_name]}", "--version=#{version}"
    end
  end

  def latest
    unless @latest
      raw_output = npackdcl 'info', "--package=#{@resource[:pkg_name]}"
      @latest = raw_output.match(/^Versions: (.*)$/)[1].split(',')[-1].strip
    end
    @latest
  end
end
