require 'spec/rake/spectask'

PLUGIN = "vendor/plugins/vms"

namespace :spec do
  desc "Run the VMS spec tests"
  Spec::Rake::SpecTask.new(:vms) do |t|
    t.spec_files = FileList["#{PLUGIN}/spec/**/*_spec.rb"]
  end
end
