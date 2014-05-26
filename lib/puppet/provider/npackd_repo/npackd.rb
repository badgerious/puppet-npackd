require 'puppetx/badgerious/npackd/providercommon'

Puppet::Type.type(:npackd_repo).provide(:npackd) do
  include PuppetX::Badgerious::Npackd::ProviderCommon

  def exists?
    raw_output = npackdcl 'list-repos'
    # repos are listed one per line after a blank line
    raw_output =~ /^$\n(.*)/m
    repos = $1.split("\n")
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
    npackdcl 'detect'
  end
end
