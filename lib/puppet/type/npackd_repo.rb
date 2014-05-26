require 'uri'

Puppet::Type.newtype(:npackd_repo) do
  desc "Manages Npackd repos."

  ensurable do
    newvalue(:present) { provider.create }
    newvalue(:absent) { provider.destroy }
    defaultto(:present)
  end

  newparam(:repo) do
    isnamevar
    validate do |r| 
      uri = URI.parse(r)
      uri.is_a?(URI::HTTP) or fail "'repo' must be a valid url"
    end
    munge do |val|
      val.downcase
    end
  end
end
