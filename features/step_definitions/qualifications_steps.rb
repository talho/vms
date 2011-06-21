
When /^I drag qualification "([^\"]*)" to site "([^\"]*)"$/ do |qual, site|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site}'));
    var site = command_center.siteGrid.getStore().getAt(i);
    var marker = command_center.findMarker(site);
    command_center.map.current_hover = marker;
    i = command_center.qualsGrid.getStore().find('name', new RegExp('#{qual}'));
    if(i === -1) i = 0;
    var data = {
      selections: [command_center.qualsGrid.getStore().getAt(i)]
    };
    command_center.map.dropZone.onNodeDrop(null, {grid:command_center.qualsGrid}, null, data);
  ")
end

When /^"([^\"]*)" should( not)? be a qualification for(?: role "([^"]*)")? site "([^\"]*)" on scenario "([^\"]*)"$/ do |qual, no, role, site, scen|
  sc = Vms::Scenario.find_by_name(scen)
  si = sc.site_instances.find_by_site_id(Vms::Site.find_by_name(site))
  if(role)
    v = si.role_scenario_sites.find_by_role_id(Role.find_by_name(role))
  else
    v = si
  end

  v.qualification_list.include?(qual).should == no.nil?
end

Given /^a user has a qualification "([^\"]*)"$/ do |qual|
  # This is used to seed qualifications. It doesn't matter which user has the qualifications at this point, just as long as some user does.
  u = User.first
  u.qualification_list << qual
  u.save
end

Given /^(?:role "([^"]*)" )?site "([^\"]*)" is assigned the qualification "([^\"]*)" on scenario "([^\"]*)"$/ do |role, site, qual, scen|
  sc = Vms::Scenario.find_by_name(scen)
  si = sc.site_instances.find_by_site_id(Vms::Site.find_by_name(site))

  if(role)
    v = si.role_scenario_sites.find_by_role_id(Role.find_by_name(role))
  else
    v = si
  end

  v.qualification_list << qual
  v.save
end

When /^I right click qualification "([^\"]*)"$/ do |qual|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.qualsGrid.getStore().find('name', new RegExp('#{qual}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    command_center.showQualsContextMenu(command_center.qualsGrid, i, evt);
  ")
end

When /^"([^\"]*)" has the qualification "([^\"]*)"$/ do |name, qual|
  u = User.find_by_display_name(name)
  u.qualification_list << qual
end