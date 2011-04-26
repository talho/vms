When /^the "([^\"]*)" scenario should be created$/ do |scenario_name|
  Vms::Scenario.find_by_name(scenario_name).should_not be_nil
end

Given /^I have the scenarios "([^\"]*)"$/ do |scenarios|
  scenarios = scenarios.split(',')
  scenarios.each do |scenario|
    Factory(:scenario, :name => scenario.strip,
            :user_rights => [ Vms::UserRight.new :user => current_user, :permission_level => Vms::UserRight::PERMISSIONS[:owner]] )
  end
end
When /^I open the "([^\"]*)" scenario$/ do |name|
    When %Q{I go to the ext dashboard page}
    When %Q{I navigate to "Apps > VMS > Manage Scenarios"}
    When %Q{I select the "#{name}" grid row}
    When %Q{I press "Open"}
    When %Q{I wait for the "Loading..." mask to go away}
    When %Q{I wait for the "Loading..." mask to go away}
    Then %Q{I should see "New Site (drag to create)"}
end