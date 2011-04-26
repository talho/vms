
When /^I drag the "([^\"]*)" inventory onto the "([^\"]*)" site$/ do |inv_name, site_name|
  page.execute_script("
  var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
  var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site_name}'));
  var site = command_center.siteGrid.getStore().getAt(i);
  var marker = command_center.findMarker(site);
  command_center.map.current_hover = marker;
  i = command_center.inventoryGrid.getStore().find('name', new RegExp('#{inv_name}'));
  if(i === -1) i = 0;
  var data = {
    selections: [command_center.inventoryGrid.getStore().getAt(i)]
  };
  command_center.map.dropZone.onNodeDrop(null, null, null, data);
  ")
end

Then /^"([^\"]*)" should exist on site "([^\"]*)" for scenario "([^\"]*)" with source "([^\"]*)" and type "([^\"]*)"$/ do |inventory_name, site_name, scenario_name, source, type|
  inv = Vms::Scenario.find_by_name(scenario_name).site_instances.for_site_by_name(site_name).inventories.find_by_name(inventory_name)
  inv.should_not be_nil
  inv.site.name.should == site_name unless site_name.blank?
  inv.site.should be_nil if site_name.blank?
  inv.source.name.should == source
  inv.pod.should == (type == 'pod')
end

Then /^"([^\"]*)" on site "([^\"]*)" for scenario "([^\"]*)" should have the following items:$/ do |inventory_name, site_name, scenario_name, table|
  # table is a | name | category | quantity | consumable |
  inv = inventory_name.blank? ? nil : Vms::Scenario.find_by_name(scenario_name).site_instances.for_site_by_name(site_name).inventories.find_by_name(inventory_name)
  inv.item_collections.find_by_status(Vms::Inventory::ItemCollection::STATUS[:available]).item_instances.size.should == table.hashes.size unless inv.nil?
  table.hashes.each do |hash|
    item = Vms::Inventory::Item.find_by_name(hash[:name])
    unless inv.nil?
      item_instance = inv.item_instances.find_by_item_id(item)
      item_instance.should_not be_nil
      item_instance.quantity.should == hash[:quantity].to_i
    end
    item.item_category.name.should == hash[:category]
    item.consumable.should == (hash[:consumable] == 'true')
  end
end

Given /^the following inventories exist:$/ do |table|
  # table is a | name | site | source | type | template |
  table.hashes.each do |hash|
    scenario_site = hash[:site].blank? ? nil : Vms::Scenario.find_by_name(hash[:scenario]).site_instances.for_site(Vms::Site.find_by_name(hash[:site]))
    Factory.create(:inventory, {:name => hash[:name], :pod => hash[:type] == "pod", :template => hash[:template] == "true",
        :source => Vms::Inventory::Source.find_or_create_by_name(hash[:source]),
        :scenario_site => scenario_site
    })
  end
end

Given /^the "([^\"]*)" inventory has the following items:$/ do |inv_name, table|
  # table is a | name | category | quantity | consumable |
  it_coll = Vms::Inventory.find_by_name(inv_name).item_collections.find_or_build_by_status(Vms::Inventory::ItemCollection::STATUS[:available])
  table.hashes.each do |hash|
    cat = Vms::Inventory::ItemCategory.find_by_name(hash[:category]) || Factory.build(:item_category, :name => hash[:category])
    item = Vms::Inventory::Item.find_by_name(hash[:name]) || Factory.create(:item, :name => hash[:name], :consumable => (hash[:consumable] == 'true'), :item_category => cat)
    Factory.create(:item_instance, :item => item, :item_collection => it_coll, :quantity => hash[:quantity].to_i)
  end
end

When /^I right click on the "([^\"]*)" inventory$/ do |inv_name|
  # For now, hack right click in
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.inventoryGrid.getStore().find('name', new RegExp('#{inv_name}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    command_center.showInventoryContextMenu(command_center.inventoryGrid, i, evt);
  ")
end

When /^I right click on the "([^\"]*)" item$/ do |item_name|
  # For now, hack right click in
  page.execute_script("
    var item_window = Ext.WindowMgr.getActive();
    var item_grid = item_window.getComponent('items');
    var i = item_grid.getStore().find('name', new RegExp('#{item_name}'));
    var evt = { preventDefault: function(){} } // make fake event to not break anything
    item_window.showItemMenu(item_grid, i, evt);
  ")
end

Given /^the following items exist:$/ do |table|
  # table is a | name | category | consumable |
  table.hashes.each do |hash|
    cat = Vms::Inventory::ItemCategory.find_by_name(hash[:category]) || Factory.build(:item_category, :name => hash[:category])
    Vms::Inventory::Item.find_by_name(hash[:name]) || Factory.create(:item, :name => hash[:name], :consumable => (hash[:consumable] == 'true'), :item_category => cat)
  end
end

Then /^I should have a "([^\"]*)" template with the following items:$/ do |inventory_name, table|
  # table is a | name | category | quantity | consumable |
  inv = Vms::Inventory.find(:first, :conditions => {:name => inventory_name, :template => true})
  inv.should_not be_nil
  inv.template.should be_true
  inv.item_collections.find_by_status(Vms::Inventory::ItemCollection::STATUS[:available]).item_instances.size.should == table.hashes.size unless inv.nil?
  table.hashes.each do |hash|
    item = Vms::Inventory::Item.find_by_name(hash[:name])
    unless inv.nil?
      item_instance = inv.item_instances.find_by_item_id(item)
      item_instance.should_not be_nil
      item_instance.quantity.should == hash[:quantity].to_i
    end
    item.item_category.name.should == hash[:category]
    item.consumable.should == (hash[:consumable] == 'true')
  end
end

Then /^the site "([^\"]*)" for scenario "([^\"]*)" should have no inventories$/ do |site_name, scenario_name|
  Vms::Scenario.find_by_name(scenario_name).site_instances.for_site(Vms::Site.find_by_name(site_name)).inventories.should be_empty
end

When /^inventories "([^\"]*)" are assigned to "([^\"]*)" for scenario "([^\"]*)"$/ do |inventory_name, site_name, scenario_name|
  case inventory_name
    when "One Item"
      Given "the following inventories exist:", table(%{
        | name        | site         | scenario         | source | type      | template |
        | Inventory 1 | #{site_name} | #{scenario_name} | source | inventory | false    |
      })
      Given %{the "Inventory 1" inventory has the following items:}, table(%{
        | name   | category | quantity | consumable |
        | Item 1 | supplies | 10       | false      |
      })
    when "Many Items"
      Given "the following inventories exist:", table(%{
        | name        | site         | scenario         | source | type      | template |
        | Inventory 1 | #{site_name} | #{scenario_name} | source | inventory | false    |
      })
      Given %{the "Inventory 1" inventory has the following items:}, table(%{
        | name   | category | quantity | consumable |
        | Item 1 | supplies | 10       | false      |
        | Item 2 | supplies | 10       | false      |
      })
    when "Many Inventories"
      Given "the following inventories exist:", table(%{
        | name        | site         | scenario         | source | type      | template |
        | Inventory 1 | #{site_name} | #{scenario_name} | source | inventory | false    |
        | Inventory 2 | #{site_name} | #{scenario_name} | source | inventory | false    |
      })
      Given %{the "Inventory 1" inventory has the following items:}, table(%{
        | name   | category | quantity | consumable |
        | Item 1 | supplies | 10       | false      |
      })
      Given %{the "Inventory 2" inventory has the following items:}, table(%{
        | name   | category | quantity | consumable |
        | Item 1 | supplies | 10       | false      |
      })
    when "Out of Items"
      Given "the following inventories exist:", table(%{
        | name        | site         | scenario         | source | type      | template |
        | Inventory 1 | #{site_name} | #{scenario_name} | source | inventory | false    |
      })
      Given %{the "Inventory 1" inventory has the following items:}, table(%{
        | name   | category | quantity | consumable |
        | Item 1 | supplies | 10       | false      |
        | Item 2 | supplies | 0        | false      |
      })
  end
end