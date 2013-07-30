module PuppetX
module Badgerious
module Npackd
module ProviderCommon
  def self.included(base)
    base.class_exec do
      confine :osfamily => :windows
      defaultfor :osfamily => :windows
      commands :npackdcl => File.join(ENV['ProgramFiles'].to_s, 'NpackdCL', 'npackdcl.exe')
    end
  end
end
end
end
end
