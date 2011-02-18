require 'factory_girl'

Factory.sequence(:scenario_name) {|jn| "Scenario #{jn}"}
Factory.define :scenario, :class => Vms::Scenario do |m|
  m.name {Factory.next(:scenario_name)}
  m.association :creator, :factory => :user
  m.state Vms::Scenario::STATES[:unexecuted]
end

Factory.define :scenario_site, :class => Vms::ScenarioSite do |m|
  m.association :scenario, :factory => :scenario
  m.status Vms::ScenarioSite::STATES[:inactive]
end

Factory.sequence(:site_name) {|jn| "Site #{jn}"}
Factory.define :site, :class => Vms::Site do |m|
  m.name {Factory.next(:site_name)}
  m.association :scenario_instances, :factory => :scenario_site
end

Factory.sequence(:inventory_name) {|jn| "Inventory #{jn}"}
Factory.define :inventory, :class => Vms::Inventory do |m|
  m.name {Factory.next(:inventory_name)}
  m.template 0
  m.association :source, :factory => :inventory_source
  m.item_collections { |ic| [ic.association(:item_collection)] }
end

Factory.sequence(:inventory_source_name) {|n| "Source #{n}"}
Factory.define :inventory_source, :class => Vms::Inventory::Source do |m|
  m.name {Factory.next(:inventory_source_name)}
end

Factory.define :item_collection, :class => Vms::Inventory::ItemCollection do |m|
  m.status Vms::Inventory::ItemCollection::STATUS[:available]
end

Factory.define :item_instance, :class => Vms::Inventory::ItemInstance do |m|
  m.quantity 0
  m.association :item, :factory => :item
end

Factory.sequence(:item_name) {|n| "Item #{n}"}
Factory.define :item, :class => Vms::Inventory::Item do |m|
  m.name {Factory.next(:item_name)}
  m.consumable 0
  m.association :item_category, :factory => :item_category
end

Factory.sequence(:item_category_name) {|n| "Category #{n}"}
Factory.define :item_category, :class => Vms::Inventory::ItemCategory do |m|
  m.name {Factory.next(:item_category_name)}
end
