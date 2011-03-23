When /^I drag team "([^\"]*)" to the "([^\"]*)" site$/ do |team, site|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site}'));
    var site = command_center.siteGrid.getStore().getAt(i);
    var marker = command_center.findMarker(site);
    command_center.map.current_hover = marker;
    i = command_center.teamsGrid.getStore().find('name', new RegExp('#{team}'));
    if(i === -1) i = 0;
    var data = {
      selections: [command_center.teamsGrid.getStore().getAt(i)]
    };
    command_center.map.dropZone.onNodeDrop(null, null, null, data);
  ")
end

When /^"([^\"]*)" should( not)? be a team assigned to site "([^\"]*)", scenario "([^\"]*)"$/ do |team, neg, site, scenario|
  scen = Vms::Scenario.find_by_name(scenario)
  si = scen.site_instances.for_site(Vms::Site.find_by_name(site))
  te = si.teams.find_by_audience_id(Audience.find_by_name(team, :conditions => {:type => nil, :scope => 'Team'}))
  if neg.nil?
    te.should_not be_nil
  else
    te.should be_nil
  end
end

When /^"([^\"]*)" should( not)? be a member of the "([^\"]*)" (audience|team|group)$/ do |user, neg, audience, type|
  if type == 'team'
    te = Audience.find_by_name(audience, :conditions => {:type => 'Group', :scope => 'Team'})
  elsif type == 'group'
    te = Audience.find_by_name(audience, :conditions => {:type => 'Group', :scope => ['Personal', 'Jurisdiction', 'Global']})
  else
    te = Audience.find_by_name(audience, :conditions => {:type => nil})
  end
  user = te.users.find_by_display_name(user)

  if neg.nil?
    user.should_not be_nil
  else
    user.should be_nil
  end
end

When /^a team should exist named "([^\"]*)" with ([\d]+) sub audience$/ do |team, num|
  te = Audience.find_by_name(team, :conditions => {:type => 'Group', :scope => 'Team'})
  te.should_not be_nil
  te.sub_audiences.count.should == num.to_i
end

Transform /^ assigned to site "([^\"]*)" scenario "([^\"]*)"$/ do |site, scenario|
  scen = Vms::Scenario.find_by_name(scenario)
  si = scen.site_instances.for_site(Vms::Site.find_by_name(site))
  si
end

Given /^a team "([^\"]*)"( assigned to site "(?:[^\"]*)" scenario "(?:[^\"]*)")?( templated)? with$/ do |team_name, site_instance, templated, table|
  users = []
  table.raw.each do |row|
    users << User.find_by_display_name(row[0])
  end

  type = site_instance.nil? ? 'group' : 'audience'
  aud = Factory.create(type.to_sym, :name => team_name, :users => users, :scope => 'Team', :owner_id => current_user.id)
  unless site_instance.nil?
    Factory.create(:team, :scenario_site => site_instance, :audience => aud)
    unless templated.nil?
      Factory.create(:group, :name => aud.name, :users => aud.users, :scope => 'Team', :owner_id => current_user.id)
    end
  end
end

When /^I right click on the team "([^\"]*)"$/ do |team|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.teamsGrid.getStore().find('name', new RegExp('#{team}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    command_center.showTeamContextMenu(command_center.teamsGrid, i, evt);
  ")
end

Given /^team "([^\"]*)" was derived from group "([^\"]*)"$/ do |team, group|
  te = Audience.find_by_name(team, :conditions => {:type => nil})
  te.parent_audiences << Group.find_by_name(group, :conditions => {:scope => ['Personal', 'Jurisdiction', 'Global']})
end