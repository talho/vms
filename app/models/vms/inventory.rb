class Vms::Inventory < ActiveRecord::Base
    set_table_name "vms_inventories"

    belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
    has_one :site, :through => :scenario_site, :class_name => "Vms::Site"
    belongs_to :source, :class_name => "Vms::Inventory::Source"
    has_many :item_collections, :class_name => "Vms::Inventory::ItemCollection" do
      def find_or_build_by_status(st)
        find_by_status(st) || build(:status => st)
      end
    end
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
    
    named_scope :templates, :conditions => {:template => true} do
      def by_name(name)
        scoped :conditions => "name LIKE '%#{name}%'"
      end
    end
    
    def clone
      #create new inventory with the attributes of the old
      inv = Vms::Inventory.new(self.attributes)
      inv.template = false # make sure template is set to false on a copy
      
      #copy the item collections from the template
      self.item_collections.each do |tic|
        ic = inv.item_collections.build(:status => tic.status)
        tic.item_instances.each do |tii|
          ic.item_instances.build(tii.attributes)
        end
      end
      
      inv
    end
end
