module PuppetX
module Badgerious
module Npackd
module ProviderCommon
  def self.included(base)
    base.class_exec do
      confine :osfamily => :windows
      defaultfor :osfamily => :windows
      confine :true => ENV.include?('NPACKD_CL')
      # to_s in case ENV['NPACKD_CL'] is nil
      commands :npackdcl => File.join(ENV['NPACKD_CL'].to_s, 'npackdcl.exe')
    end
  end
end
end
end
end
