
class Vms::ScenarioSite < ActiveRecord::Base  
  set_table_name "vms_scenario_site"

  acts_as_taggable_on :qualifications

  belongs_to :site, :class_name => "Vms::Site"
  belongs_to :scenario, :class_name => "Vms::Scenario"
  belongs_to :site_admin, :class_name => "User"
  STATES = {:inactive => 1, :active => 2}  
  
  has_many :inventories, :class_name => "Vms::Inventory"
  has_many :role_scenario_sites, :class_name => "Vms::RoleScenarioSite", :autosave => true
  has_many :roles, :through => :role_scenario_sites
  has_many :staff, :class_name => "Vms::Staff", :autosave => true
  has_many :users, :through => :staff
  has_many :teams, :class_name => "Vms::Team", :autosave => true
  
  def as_json (options = {})
    options[:include] = {} if options[:include].nil?
    options[:include].merge! :site => {}
    json = super(options)    
    ( json.key?("scenario_site") ? json["scenario_site"] : json).merge!( 
      {:qualifications => qualification_list.map(&:titleize).join(', ')})
    json   
  end
  
  def complete_qualification_list
    tags = []
    tags << qualification_list.map { |q| {:name => q, :site_id => site_id, :site => site.name} }
    tags << role_scenario_sites.map { |r| r.qualification_list.map { |q| {:name => q, :role => r.role.name, :role_id => r.role_id, :site_id => site_id, :site => site.name} } }
    tags
  end

  def to_s
    Vms::Site.find(site_id).name  + ': ' + Vms::Scenario.find(scenario_id).name
  end
end