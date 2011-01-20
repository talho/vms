When /^the "([^\"]*)" scenario should be created$/ do |scenario_name|
  Vms::Scenario.find_by_name(scenario_name).should_not be_nil
end

Given /^I have the scenarios "([^\"]*)"$/ do |scenarios|
  scenarios = scenarios.split(',')
  scenarios.each do |scenario|
    Factory(:scenario, :name => scenario.strip, :creator => current_user)
  end
end