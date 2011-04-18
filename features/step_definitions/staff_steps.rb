
When /^I drag staff "([^\"]*)" to "([^\"]*)"$/ do |staff, site|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site}'));
    var site = command_center.siteGrid.getStore().getAt(i);
    var marker = command_center.findMarker(site);
    command_center.map.current_hover = marker;
    i = command_center.staffGrid.getStore().find('name', new RegExp('#{staff}'));
    if(i === -1) i = 0;
    var data = {
      selections: [command_center.staffGrid.getStore().getAt(i)]
    };
    command_center.map.dropZone.onNodeDrop(null, null, null, data);
  ")
end

Then /^"([^\"]*)" should( not)? be assigned to "([^\"]*)" for scenario "([^\"]*)"$/ do |neg, staff, site_name, scenario_name|
  scenario = Vms::Scenario.find_by_name(scenario_name)
  site_instance = scenario.site_instances.for_site(Vms::Site.find_by_name(site_name))
  user = site_instance.staff.find_by_user_id(User.find_by_display_name(staff))
  if neg.nil?
    user.should_not be_nil
  else
    user.should be_nil
  end
end

Given /^"([^\"]*)" is assigned to "([^\"]*)" for scenario "([^\"]*)"$/ do |staff_name, site_name, scenario_name|
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.for_site(Vms::Site.find_by_name(site_name))
  user = User.find_by_display_name(staff_name)
  Factory.create(:staff, {:user => user, :scenario_site => scenario_site})
end

When /^I right click on staff group "([^\"]*)"$/ do |group_name|
  group_header = page.find('.x-grid-group-hd', :text => group_name)
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.staffGrid.getStore().find('site', new RegExp('#{group_name}'));
    var r = command_center.staffGrid.getStore().getAt(i);
    var evt = { preventDefault: function(){},
                getTarget: function(){ return Ext.get('#{group_header['id']}'); }
    } // make fake event to not break anything
    command_center.showStaffGroupContextMenu(command_center.staffGrid, 'site_id', r.get('site_id'), evt);
  ")
end

When /^I right click on staff member "([^\"]*)"$/ do |staff_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.staffGrid.getStore().find('name', new RegExp('#{staff_name}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    command_center.showStaffContextMenu(command_center.staffGrid, i, evt);
  ")
end

When /^staff "([^\"]*)" are assigned to "([^\"]*)" for scenario "([^\"]*)"$/ do |staff_name, site_name, scenario_name|
  case staff_name
    when "Just Atticus", "Atticus & Team"
      Given %{"Atticus Finch" is assigned to "#{site_name}" for scenario "#{scenario_name}"}
    when "Atticus & Bart"
      Given %{"Bartleby Scrivener" is assigned to "#{site_name}" for scenario "#{scenario_name}"}
      Given %{"Atticus Finch" is assigned to "#{site_name}" for scenario "#{scenario_name}"}
  end
end