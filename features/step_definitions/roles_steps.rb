
When /^I drag "([^\"]*)" to the "([^\"]*)" site$/ do |role, site|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site}'));
    var site = command_center.siteGrid.getStore().getAt(i);
    var marker = command_center.findMarker(site);
    command_center.map.current_hover = marker;
    i = command_center.rolesGrid.getStore().find('name', new RegExp('#{role}'));
    if(i === -1) i = 0;
    var data = {
      selections: [command_center.rolesGrid.getStore().getAt(i)]
    };
    command_center.map.dropZone.onNodeDrop(null, null, null, data);
  ")
end

Then /^the "([^\"]*)" site for scenario "([^\"]*)" should have ([\d]*) "([^\"]*)" role$/ do |site_name, scenario_name, count, role_name|
  scenario = Vms::Scenario.find_by_name(scenario_name)
  site_instance = scenario.site_instances.for_site(Vms::Site.find_by_name(site_name))
  role_instance = site_instance.role_scenario_sites.find_by_role_id(Role.find_by_name(role_name))
  role_instance.should_not be_nil
  role_instance.count.should == count.to_i
end

Given /^the site "([^\"]*)" for scenario "([^\"]*)" has the role "([^\"]*)"$/ do |site_name, scenario_name, role_name|
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.for_site(Vms::Site.find_by_name(site_name))
  role = Role.find_by_name(role_name)
  Factory.create(:role_scenario_site, {:role => role, :count => 1, :scenario_site => scenario_site})
end

Then /^the "([^\"]*)" site for scenario "([^\"]*)" should not have the "([^\"]*)" role$/ do |site_name, scenario_name, role_name|
  scenario = Vms::Scenario.find_by_name(scenario_name)
  site_instance = scenario.site_instances.for_site(Vms::Site.find_by_name(site_name))
  role_instance = site_instance.role_scenario_sites.find_by_role_id(Role.find_by_name(role_name))
  role_instance.should be_nil
end

When /^right click the "([^\"]*)" role$/ do |role_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.rolesGrid.getStore().find('name', new RegExp('#{role_name}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    command_center.showRolesContextMenu(command_center.rolesGrid, i, evt);
  ")
end

When /^right click the "([^\"]*)" role group header$/ do |role_group_name|
  group_header = page.find('.x-grid-group-hd', :text => role_group_name)
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.rolesGrid.getStore().find('site', new RegExp('#{role_group_name}'));
    var r = command_center.rolesGrid.getStore().getAt(i);
    var evt = { preventDefault: function(){},
                getTarget: function(){ return Ext.get('#{group_header['id']}'); }
    } // make fake event to not break anything
    command_center.showRolesGroupContextMenu(command_center.rolesGrid, 'site_id', r.get('site_id'), evt);
  ")
end

When /^I drag role group "([^\"]*)" to "([^\"]*)"$/ do |role_group_name, site_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site_name}'));
    var site = command_center.siteGrid.getStore().getAt(i);
    var marker = command_center.findMarker(site);
    command_center.map.current_hover = marker;
    i = command_center.rolesGrid.getStore().find('site', new RegExp('#{role_group_name}'));
    var r = command_center.rolesGrid.getStore().getAt(i);
    var data = r.get('site_id');
    command_center.map.dropZone.onNodeDrop(null, null, null, data);
  ")
end