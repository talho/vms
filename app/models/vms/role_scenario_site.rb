
class Vms::RoleScenarioSite < ActiveRecord::Base  
  set_table_name "vms_roles_scenario_sites"
  
  belongs_to :role
  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("role_scenarios_site_instance") ? json["role_scenarios_site_instance"] : json).merge!( 
      {:site => site.name, :site_id => site.id, :role => role.name })
    json
  end
end