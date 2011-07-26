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
                    
$menu_config[:vms] = <<EOF
  nav = "{name: 'VMS', items:["
  if current_user.vms_admin?
    nav += "{name: 'Manage Scenarios', tab:{id: 'vms_open_scenario', title:'Manage Scenarios', initializer: 'Talho.VMS.Scenario.Manager'}},
            {name: 'Volunteer List', tab: {id: 'vms_volunteer_list', title:'Volunteer List', initializer: 'Talho.VMS.Volunteer.List'}},
            {name: 'Site Administration', win:{id: 'vms_site_admin', title:'Site Administration', initializer: 'Talho.VMS.AdministerSites'}}"
    nav += "," if current_user.vms_volunteer?
  end
  nav += "{name: 'My Volunteer Profile', tab:{id: 'vms_user_profile', title:'My Volunteer Profile', initializer: 'Talho.VMS.User.Profile'}}" if current_user.vms_volunteer?
  nav += "]}"
EOF

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :vms => [ "vms/script_config" ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :vms => [ "vms/vms" ])

module Vms
end
