

When /^I drag the "([^\"]*)" site to the map at "([^"]*)", "([^"]*)"$/ do |sitename, lat, lng|
  # have to do this all in JS because the selenium driver is not good enough to figure it out for itself

  page.execute_script("
  var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
  var i = command_center.siteGrid.getStore().find('name', new RegExp('#{sitename}'));
  if(i === -1) i = 0;
  var data = {
    selections: [command_center.siteGrid.getStore().getAt(i)]
  };
  command_center.map.dropZone.onContainerDrop(null, null, data, {lat: #{lat}, lng: #{lng}});
  ")
end

When /^the site "([^\"]*)" should exist at "([^\"]*)", "([^\"]*)", "([^\"]*)"$/ do |site_name, address, lat, lng|
  site = Vms::Site.find_by_name(site_name)
  site.should_not be nil
  site.address.should == address
  site.lat.to_f.round(6).should == lat.to_f.round(6)
  site.lng.to_f.round(6).should == lng.to_f.round(6)
end

Given /^the following sites exist:$/ do |table|
  # table is a | name | address | lat | lng | status | scenario |
  table.hashes.each do |row|
    scenario_sites = []
    unless row[:scenario].blank?
      scenario_sites.push(Factory.build(:scenario_site, {:scenario => Vms::Scenario.find_by_name(row[:scenario]),
                                                         :status => Vms::ScenarioSite::STATES[row[:status].to_sym]}))
    end
    Factory.create(:site, :name => row[:name], :address => row[:address], :lat => row[:lat], :lng => row[:lng], :scenario_instances => scenario_sites )
  end
end

When /^I right click on site "([^"]*)"$/ do |site_name|
  # For now, hack right click in
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site_name}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    command_center.showSiteContextMenu(command_center.siteGrid, i, evt);
  ")
end

Then /^the site "([^\"]*)" should be "([^\"]*)" for scenario "([^\"]*)"$/ do |site_name, status, scenario_name|
  site_instance = Vms::Scenario.find_by_name(scenario_name).site_instances.for_site(Vms::Site.find_by_name(site_name)[:id])
  site_instance.status.should == Vms::ScenarioSite::STATES[status.to_sym]
end