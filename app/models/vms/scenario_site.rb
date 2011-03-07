
class Vms::ScenarioSite < ActiveRecord::Base  
  set_table_name "vms_scenario_site"

  belongs_to :site, :class_name => "Vms::Site"
  belongs_to :scenario, :class_name => "Vms::Scenario"
  STATES = {:inactive => 1, :active => 2}  
  
  has_many :inventories, :class_name => "Vms::Inventory"
  has_many :role_scenario_sites, :class_name => "Vms::RoleScenarioSite", :autosave => true
  has_many :roles, :through => :role_scenario_sites
  has_many :staff, :class_name => "Vms::Staff", :autosave => true
  has_many :users, :through => :staff
  
  def as_json (options = {})
    options[:include] = {} if options[:include].nil?
    options[:include].merge! :site => {}
    super(options)    
  end
end