When /^the "([^\"]*)" scenario should be created$/ do |scenario_name|
  Vms::Scenario.find_by_name(scenario_name).should_not be_nil
end

Given /^([^ ]*) (?:have|has) the scenarios? "([^\"]*)"$/ do |email, scenarios| 
  email == "I" ? user = current_user : user = User.find_by_email(email)
  scenarios = scenarios.split(',')
  scenarios.each do |scenario|
    Factory(:scenario, :name => scenario.strip,
            :user_rights => [ Vms::UserRight.new :user => user, :permission_level => Vms::UserRight::PERMISSIONS[:owner]] )
  end
end
When /^I open the "([^\"]*)" scenario$/ do |name|
    When %Q{I go to the ext dashboard page}
    When %Q{I navigate to "Apps > VMS > Manage Scenarios"}
    When %Q{I select the "#{name}" grid row}
    When %Q{I click vms-row-button "Open Scenario"}
    Then %Q{the "Command Center - #{name}" tab should be open}
    When %Q{I wait for the "Loading..." mask to go away}
    When %Q{I wait for the "Loading..." mask to go away}
    Then %Q{I should see "New Site (drag to create)"}
end

Then /^"([^\"]*)" should be an? ([a-zA-Z0-9\-_]*) for scenario "([^\"]*)"$/ do |user_name, role, scenario|
  user = User.find_by_display_name(user_name)
  scen = Vms::Scenario.find_by_name(scenario)
  ur = scen.user_rights.find_by_user_id(user)
  ur.should_not be_nil
  ur.permission_level.should == Vms::UserRight::PERMISSIONS[role.to_sym]
end

Given /^"([^\"]*)" is an? ([a-zA-Z0-9\-_]*) for scenario "([^\"]*)"$/ do |user_name, role_name, scenario_name|
  user = User.find_by_display_name(user_name)
  scen = Vms::Scenario.find_by_name(scenario_name)
  scen.user_rights.create :user => user, :permission_level => Vms::UserRight::PERMISSIONS[role_name.to_sym]
end

Given /^scenario "([^\"]*)" is "([^\"]*)"$/ do |scenario_name, scenario_status|
  scen = Vms::Scenario.find_by_name(scenario_name)
  scen.update_attributes :state => Vms::Scenario::STATES[scenario_status.to_sym]
end

Then /^scenario "([^\"]*)" should be "([^\"]*)"$/ do |scenario_name, scenario_status|
  scen = Vms::Scenario.find_by_name(scenario_name)
  scen.state.should == Vms::Scenario::STATES[scenario_status.to_sym]
end

Then /^the polling service for "([^"]*)" should( not)? be running$/ do |scenario_name, neg|
  scen = Vms::Scenario.find_by_name(scenario_name)

  connected = page.evaluate_script("Ext.Direct.getProvider('command_center_polling_provider-#{scen.id.to_s}').isConnected()")

  if neg
    connected.should be_false
  else
    connected.should be_true
  end
end

When /^I drag "([^\"]*)" to "([^\"]*)" in the (.*) grid$/ do |item_name, dest_name, item_type|
  page.execute_script("
  var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
  var dest_i = command_center.#{item_type}Grid.getStore().find('name', new RegExp('#{dest_name}'));
  var i = command_center.#{item_type}Grid.getStore().find('name', new RegExp('#{item_name}'));
  if(i === -1) i = 0;
  var data = {
    grid: command_center.#{item_type}Grid,
    rowIndex: i,
    selections: [command_center.#{item_type}Grid.getStore().getAt(i)]
  };
  var e = {
    getTarget: function(){
      return undefined;
    },
    target: command_center.#{item_type}Grid.getView().getRow(dest_i)
  };
  command_center.#{item_type}Grid.dropTarget.notifyDrop(null, e, data);
  ")
end