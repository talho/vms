Then /^"([^"]*)" should be the site administrator for "([^"]*)" in "([^"]*)"$/ do |email, site_name, scenario_name|
  site = Vms::Site.find_by_name(site_name)
  scenario = Vms::Scenario.find_by_name(scenario_name)
  user = User.find_by_email(email)
  Vms::ScenarioSite.find_by_site_id_and_scenario_id(site.id,scenario.id).site_admin.should == user
end

Given /^"([^"]*)" is the site administrator for "([^"]*)" in "([^"]*)"$/ do |email, site_name, scenario_name|
  site = Vms::Site.find_by_name(site_name)
  scenario = Vms::Scenario.find_by_name(scenario_name)
  user = User.find_by_email(email)
  Vms::ScenarioSite.find_by_site_id_and_scenario_id(site.id,scenario.id).update_attribute(:site_admin_id, user.id)
end
