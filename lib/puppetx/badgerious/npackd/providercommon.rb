module PuppetX
module Badgerious
module Npackd
module ProviderCommon
  def self.included(base)
    base.class_exec do
      confine :osfamily => :windows
      defaultfor :osfamily => :windows
      # FIXME: this seems to cause weird errors. Specifically, "can't convert nil into String" (?)
      commands :npackdcl => File.join(ENV['ProgramFiles'], 'NpackdCL', 'npackdcl.exe')
    end
  end
end
end
end
end
