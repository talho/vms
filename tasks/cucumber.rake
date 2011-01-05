begin
  require 'cucumber/rake/task'

  ENV["RAILS_ENV"] ||= "cucumber"

  namespace :cucumber do
    desc = "Vms plugin, add any cmd args after --"
    Cucumber::Rake::Task.new({:vms => 'db:test:prepare'}, desc) do |t|
      t.cucumber_opts = "-r features " +
                        "-r vendor/plugins/vms/spec/factories.rb " +
                        "-r vendor/plugins/vms/features/step_definitions " +
                        " #{ARGV[1..-1].join(" ") if ARGV[1..-1]}" +
                        # add all Vms features if none are passed in
                        (ARGV.grep(/^vendor/).empty? ? "vendor/plugins/vms/features" : "")
      t.fork = true
      t.profile = 'default'
    end
  end
rescue LoadError
  # to catch if cucmber is not installed, as in production
end
