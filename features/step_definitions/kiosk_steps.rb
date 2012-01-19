Given /^"([^"]*)" should be checked (in|out) as a walk\-up volunteer at "([^"]*)" for scenario "([^"]*)"$/ do |walkup_name, inout, site_name, scenario_name|
  name = walkup_name.split(' ')
  walkup = Vms::Walkup.find_by_first_name_and_last_name(name.first, name.last)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find_by_site_id(Vms::Site.find_by_name(site_name).id)
  if inout == 'in'
    walkup.scenario_site_id.should == scenario_site.id && walkup.checked_in.should == true
  else
    walkup.scenario_site_id.should == scenario_site.id && walkup.checked_in.should_not == true
  end
end

Given /^I force open the kiosk page for "([^"]*)" in scenario "([^"]*)"$/ do |site_name, scenario_name|
  site = Vms::Site.find_by_name(site_name)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find(site.id)
  Then %{I visit the url "/vms/kiosk/#{scenario_site.id}"}
end

Given /^I maliciously attempt to check in as "([^"]*)" to site "([^"]*)" in scenario "([^"]*)"$/ do |email, site_name, scenario_name|
  user = User.find_by_email(email)
  site = Vms::Site.find_by_name(site_name)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find(site.id)
  Then %{I maliciously post formdata to "/vms/site_checkin.json"}, table(%{
    | email             | #{user.id}     |
    | password          | Password1           |
    | id                | #{scenario_site.id} |
  })
end

Given /^I maliciously attempt to check in as a walkup user to site "([^"]*)" in scenario "([^"]*)"$/ do |site_name, scenario_name|
  site = Vms::Site.find_by_name(site_name)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find(site.id)
  Then %{I maliciously post formdata to "/vms/site_walkup.json"}, table(%{
    | walkup_email      | badguy@example.com  |
    | walkup_first_name | Bad                 |
    | walkup_last_name  | Guy                 |
    | id                | #{scenario_site.id} |
  })
end

Given /^no (user|walkup) should be checked in to site "([^"]*)" in scenario "([^"]*)"$/ do |volunteer_type, site_name, scenario_name|
  site = Vms::Site.find_by_name(site_name)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find(site.id)
  case volunteer_type
    when 'user'
      scenario_site.staff.collect(&:checked_in).uniq.include?(true).should_not == true
    when 'phin'
      scenario_site.walkups.count.should == 0
  end
end

Given /^I maliciously attempt to fetch kiosk information for site "([^"]*)" in scenario "([^"]*)"$/ do |site_name, scenario_name|
  site = Vms::Site.find_by_name(site_name)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find(site.id)
  Then %{I visit the url "/vms/kiosk/#{scenario_site.id}.json"}
end

