require 'inflections'

# Require VMS models
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each do |f|
  require f
end

# Add PLUGIN_NAME vendor/plugins/*/lib to LOAD_PATH
Dir[File.join(File.dirname(__FILE__), '../vendor/plugins/*/lib')].each do |path|
  $LOAD_PATH << path
end

# Require any submodule dependencies here
# For example, if this depended on open_flash_chart you would require init.rb as follows:
#   require File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'open_flash_chart', 'init.rb')

# Register the plugin expansion in the $expansion_list global variable
$expansion_list = [] unless defined?($expansion_list)
$expansion_list.push(:vms) unless $expansion_list.index(:vms)

$menu_config = {} unless defined?($menu_config)
$menu_config[:vms] = "{name: 'VMS', items:[
                    {name: 'New Scenario', win:{id: 'vms_new_scenario', title:'New Scenario', initializer: 'Talho.VMS.CreateAndEditScenario'}},
                    {name: 'Manage Scenarios', win:{id: 'vms_open_scenario', title:'Manage Scenarios', initializer: 'Talho.VMS.ManageScenarios'}}
                    ]}"

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :vms => [ "vms/script_config" ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :vms => [ "vms/vms" ])

module Vms
end
