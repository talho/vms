class CreateInventory < ActiveRecord::Migration
  def self.up
    create_table :vms_inventories do |t|
      t.integer :scenario_site_id
      t.index :scenario_site_id
      t.integer :source_id
      t.string :name
      t.boolean :pod, :default => false
      t.boolean :template, :default => false
    end
    
    create_table :vms_inventory_sources do |t|
      t.string :name
    end
    
    create_table :vms_inventory_item_collections do |t|
      t.integer :inventory_id
      t.index :inventory_id
      t.integer :user_id
      t.index :user_id
      t.integer :status
      t.index :status
    end
    
    create_table :vms_inventory_item_instances do |t|
      t.integer :item_collection_id
      t.index :item_collection_id
      t.integer :item_id
      t.index :item_id
      t.integer :quantity
    end
    
    create_table :vms_inventory_items do |t|
      t.string :name
      t.integer :item_category_id
      t.boolean :consumable, :default => false
    end
    
    create_table :vms_inventory_item_categories do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :vms_inventories
    drop_table :vms_inventory_sources
    drop_table :vms_inventory_item_collections
    drop_table :vms_inventory_item_instances
    drop_table :vms_inventory_items
    drop_table :vms_inventory_item_categories
  end
end
