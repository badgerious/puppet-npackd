require 'puppetx/badgerious/npackd/providercommon'

Puppet::Type.type(:npackd_repo).provide(:npackd) do
  include PuppetX::Badgerious::Npackd::ProviderCommon

  def self.get_repo_list
    raw_output = npackdcl 'list-repos'
    # repos are listed one per line after a blank line
    raw_output =~ /^$\n(.*)/m
    $1.split("\n")
  end

  def self.instances
    get_repo_list.map do |repo|
      new(:name => repo, :repo => repo)
    end
  end

  def exists?
    repos = self.class.get_repo_list
    repos.each { |r| return true if r.downcase == @resource[:repo] }
    false
  end

  def create
    debug "Adding repo '#{@resource[:repo]}'"
    npackdcl 'add-repo', "--url=#{@resource[:repo]}"
    detect
  end

  def destroy
    debug "Removing repo '#{@resource[:repo]}'"
    npackdcl 'remove-repo', "--url=#{@resource[:repo]}"
    detect
  end

  private

  def detect
    debug "Reloading npackd repos"
    begin
      npackdcl 'detect'
    rescue => e
      warning("Failed to reload npackd repos: #{e.message}")
    end
  end
end
