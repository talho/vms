class Vms::Inventory < ActiveRecord::Base
    set_table_name "vms_inventories"

    belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
    belongs_to :source, :class_name => "Vms::Inventory::Source"
    has_many :item_collections, :class_name => "Vms::Inventory::ItemCollection"
    has_many :item_instances, :through => :item_collections, :class_name => "Vms::Inventory::ItemInstance"
    
    has_many :items, :class_name => "Vms::Inventory::Item", :finder_sql => '
    SELECT items.* 
    FROM vms_inventory_item_collections ic 
    JOIN vms_inventory_item_instances ii ON ic.id = ii.item_collection_id
    JOIN vms_inventory_items items ON ii.item_id = items.id
    WHERE ic.inventory_id = "#{id}" 
    '
    
    has_many :available_items, :class_name => "Vms::Inventory::Item", :finder_sql => '
    SELECT items.* 
    FROM vms_inventory_item_collections ic 
    JOIN vms_inventory_item_instances ii ON ic.id = ii.item_collection_id
    JOIN vms_inventory_items items ON ii.item_id = items.id
    WHERE ic.inventory_id = "#{id}" AND ic.status = 1
    '
    
    TYPE = {:inventory => 1, :pod => 2}
end
