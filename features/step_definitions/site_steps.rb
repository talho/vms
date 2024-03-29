

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
      scenario_sites.push(FactoryGirl.build(:scenario_site, {:scenario => Vms::Scenario.find_by_name(row[:scenario]),
                                                         :status => Vms::ScenarioSite::STATES[row[:status].to_sym]}))
    end
    FactoryGirl.create(:site, :name => row[:name], :address => row[:address], :lat => row[:lat], :lng => row[:lng], :scenario_instances => scenario_sites )
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

# allow for site templates, using other step definitions
Given /^the site "([^\"]*)" exists for scenario "([^\"]*)"$/ do |site_name, scenario_name|
  case site_name
    when "Malawi"
      step "the following sites exist:", table(%{
        | name                | address                                 | lat                 | lng              | status | scenario     |
        | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | #{scenario_name} |
      })
    when "Immunization Center"
      step "the following sites exist:", table(%{
        | name                | address                                 | lat       | lng       | status | scenario     |
        | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | #{scenario_name} |
      })
  end
end

When /^I drag "([^\"]*)" \(([^\)]*)\) to the "([^\"]*)" site$/ do |item_name, item_type, site_name|
  page.execute_script("
  var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
  var dest_i = command_center.siteGrid.getStore().find('name', new RegExp('#{site_name}'));
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
    target: command_center.siteGrid.getView().getRow(dest_i)
  };
  command_center.siteGrid.dropTarget.notifyDrop(null, e, data);
  ")
end

Then /^the site "([^\"]*)" should( not)? exist for scenario "([^\"]*)"$/ do |site_name, neg, scen_name|
  site_instance = Vms::Scenario.find_by_name(scen_name).site_instances.for_site(Vms::Site.find_by_name(site_name)[:id])
  if neg.nil?
    site_instance.should_not be_nil
  else
    site_instance.should be_nil
  end
end