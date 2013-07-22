require 'puppetx/badgerious/npackd/providercommon'
if Puppet.features.microsoft_windows?
  require 'win32/registry'
  require 'windows/error'
  module Win32
    class Registry
      KEY_WOW64_64KEY = 0x0100 unless defined?(KEY_WOW64_64_KEY)
    end
  end
end

Puppet::Type.type(:npackd_repo).provide(:npackd) do
  include PuppetX::Badgerious::Npackd::ProviderCommon

  if Puppet.features.microsoft_windows?
    self::REG_HIVE = Win32::Registry::HKEY_LOCAL_MACHINE
    self::REG_PATH = 'SOFTWARE\Npackd\Npackd\Reps'
    self::FLAGS = Win32::Registry::KEY_ALL_ACCESS | Win32::Registry::KEY_WOW64_64KEY
  end

  def exists?
    size = 0
    self.class::REG_HIVE.open(self.class::REG_PATH, self.class::FLAGS) { |key| size = key['size'] }
    1.upto(size) do |n|
      self.class::REG_HIVE.open("#{self.class::REG_PATH}\\#{n}", self.class::FLAGS) do |key|
        return true if key['repository'] == @resource[:repo]
      end
    end
    false
  rescue Win32::Registry::Error => error
    if error.code == Windows::Error::ERROR_FILE_NOT_FOUND
      false
    else
      raise error
    end
  end

  def create
    debug "Adding repo '#{@resource[:repo]}'"
    npackdcl 'add-repo', "--url=#{@resource[:repo]}"
  end

  def destroy
    debug "Removing repo '#{@resource[:repo]}'"
    npackdcl 'remove-repo', "--url=#{@resource[:repo]}"
  end
end
