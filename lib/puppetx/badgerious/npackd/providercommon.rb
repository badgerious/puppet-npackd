module PuppetX
module Badgerious
module Npackd
module ProviderCommon
  def self.included(base)
    base.class_exec do
      confine :osfamily => :windows
      defaultfor :osfamily => :windows
      # On 32-bit Windows, there is no %ProgramFiles(x86)% variable.
      progfiles = ENV['ProgramFiles(x86)'] || ENV['ProgramFiles']
      commands :npackdcl => File.join(progfiles.to_s, 'NpackdCL', 'npackdcl.exe')
    end
  end
end
end
end
end
