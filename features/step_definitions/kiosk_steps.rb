Then /^"([^"]*)" should be checked (in|out) as a walk\-up volunteer at "([^"]*)" for scenario "([^"]*)"$/ do |walkup_name, inout, site_name, scenario_name|
  name = walkup_name.split(' ')
  walkup = Vms::Walkup.find_by_first_name_and_last_name(name.first, name.last)
  scenario_site = Vms::Scenario.find_by_name(scenario_name).site_instances.find_by_site_id(Vms::Site.find_by_name(site_name).id)
  if inout = 'in'
    walkup.scenario_site_id.should == scenario_site.id && walkup.checked_in.should == true
  else
    walkup.scenario_site_id.should == scenario_site.id && walkup.checked_in.should_not == true
  end
end
