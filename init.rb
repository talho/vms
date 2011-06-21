# Include hook code here
require 'vms'

# Removing this plugin from load_once_paths means it's reloaded in development mode just like rails core.
if RAILS_ENV == 'development'
  ActiveSupport::Dependencies.load_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end
