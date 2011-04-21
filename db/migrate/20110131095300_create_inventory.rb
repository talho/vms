class CreateInventory < ActiveRecord::Migration
  def self.up
    create_table :vms_inventories do |t|
      t.integer :scenario_site_id
      t.integer :source_id
      t.string :name
      t.boolean :pod, :default => false
      t.boolean :template, :default => false
    end
    
    add_index :vms_inventories, :scenario_site_id
    
    create_table :vms_inventory_sources do |t|
      t.string :name
    end
    
    add_index :vms_inventory_sources, :name, :unique => true
    
    create_table :vms_inventory_item_collections do |t|
      t.integer :inventory_id
      t.integer :user_id
      t.integer :status
    end
    
    add_index :vms_inventory_item_collections, :inventory_id
    add_index :vms_inventory_item_collections, :user_id
    add_index :vms_inventory_item_collections, :status
    
    create_table :vms_inventory_item_instances do |t|
      t.integer :item_collection_id
      t.integer :item_id
      t.integer :quantity
    end
    
    add_index :vms_inventory_item_instances, :item_collection_id
    add_index :vms_inventory_item_instances, :item_id
    
    create_table :vms_inventory_items do |t|
      t.string :name
      t.integer :item_category_id
      t.boolean :consumable, :default => false
    end
    
    add_index :vms_inventory_items, :name, :unique => true
    
    create_table :vms_inventory_item_categories do |t|
      t.string :name
    end
    
    add_index :vms_inventory_item_categories, :name, :unique => true
  end

  def self.down
    remove_index :vms_inventories, :scenario_site_id
    remove_index :vms_inventory_sources, :name
    remove_index :vms_inventory_item_collections, :inventory_id
    remove_index :vms_inventory_item_collections, :user_id
    remove_index :vms_inventory_item_collections, :status
    remove_index :vms_inventory_item_instances, :item_collection_id
    remove_index :vms_inventory_item_instances, :item_id
    remove_index :vms_inventory_items, :name
    remove_index :vms_inventory_item_categories, :name
    
    drop_table :vms_inventories
    drop_table :vms_inventory_sources
    drop_table :vms_inventory_item_collections
    drop_table :vms_inventory_item_instances
    drop_table :vms_inventory_items
    drop_table :vms_inventory_item_categories
  end
end
