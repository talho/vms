require 'factory_girl'

FactoryGirl.define do
  
  factory :scenario, :class => Vms::Scenario do
    sequence(:name) {|jn| "Scenario #{jn}"}
    state Vms::Scenario::STATES[:unexecuted]
  end
  
  factory :scenario_site, :class => Vms::ScenarioSite do
    association :scenario, :factory => :scenario
    status Vms::ScenarioSite::STATES[:inactive]
  end
  
  factory :site, :class => Vms::Site do
    sequence(:name) {|jn| "Site #{jn}"}
    association :scenario_instances, :factory => :scenario_site
  end
  
  factory :inventory, :class => Vms::Inventory do
    sequence(:name) {|jn| "Inventory #{jn}"}
    template 0
    association :source, :factory => :inventory_source
    item_collections { |ic| [ic.association(:item_collection)] }
  end
  
  factory :inventory_source, :class => Vms::Inventory::Source do
    sequence(:name) {|n| "Source #{n}"}
  end
  
  factory :item_collection, :class => Vms::Inventory::ItemCollection do
    status Vms::Inventory::ItemCollection::STATUS[:available]
  end
  
  factory :item_instance, :class => Vms::Inventory::ItemInstance do
    quantity 0
    association :item, :factory => :item
  end
  
  factory :item, :class => Vms::Inventory::Item do
    sequence(:name) {|n| "Item #{n}"}
    consumable 0
    association :item_category, :factory => :item_category
  end
  
  factory :item_category, :class => Vms::Inventory::ItemCategory do
    sequence(:name) {|n| "Category #{n}"}
  end
  
  factory :role_scenario_site, :class => Vms::RoleScenarioSite do
    count 1
  end
  
  factory :staff, :class => Vms::Staff do
    status 'assigned'
  end
  
  factory :team, :class => Vms::Team do
    association :audience
  end
  
end