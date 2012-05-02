begin
  require "rspec/core/rake_task"
  
  plugin = "vendor/plugins/vms"
  
  namespace :spec do
    desc "Run the VMS spec tests"
    RSpec::Core::RakeTask.new(:vms) do |spec|
      spec.pattern = "#{plugin}/spec/**/*_spec.rb"
    end
  end
rescue LoadError
end
