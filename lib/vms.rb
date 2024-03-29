                    
# Tell the main app that this extension exists
$extensions = [] unless defined?($extensions)
$extensions << :vms

$menu_config[:vms] = <<EOF
  if current_user.has_app?('vms')
    nav = "{name: 'VMS', items:["
    if current_user.vms_admin?
      nav += "{name: 'Manage Scenarios', tab:{id: 'vms_open_scenario', title:'Manage Scenarios', initializer: 'Talho.VMS.Scenario.Manager'}},
              {name: 'Volunteer List', tab: {id: 'vms_volunteer_list', title:'Volunteer List', initializer: 'Talho.VMS.Volunteer.List'}}"
      nav += "," if current_user.vms_volunteer? || current_user.is_vms_active_scenario_site_admin? 
    end
    if current_user.is_vms_active_scenario_site_admin?
      nav += "{name: 'Site Administration', win:{id: 'vms_site_admin', title:'Site Administration', initializer: 'Talho.VMS.AdministerSites'}}"
      nav += "," if current_user.vms_volunteer?
    end
    nav += "{name: 'My Volunteer Profile', tab:{id: 'vms_user_profile', title:'My Volunteer Profile', initializer: 'Talho.VMS.User.Profile'}}" if current_user.vms_volunteer?
    nav += "]}"
  end
EOF

$extensions_css = {} unless defined?($extensions_css)
$extensions_css[:vms] = [ "vms/vms.css" ]
$extensions_js = {} unless defined?($extensions_js)
$extensions_js[:vms] = [ "vms/script_config.js" ]
  
module Vms
  module Models
    autoload :Jurisdiction, 'vms/models/jurisdiction'
    autoload :User, 'vms/models/user'
    autoload :Role, 'vms/models/role'
  end
end

if defined? BDRB_CONFIG
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"workers"))
end

require 'vms/engine'