
class Vms::RoleScenarioSite < ActiveRecord::Base  
  self.table_name = "vms_roles_scenario_sites"
  
  include ActionView::Helpers::TextHelper
  
  acts_as_taggable_on :qualifications
  
  belongs_to :role, :class_name => "::Role"
  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.to_s}" }, :app => 'vms' }
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("role_scenarios_site_instance") ? json["role_scenarios_site_instance"] : json).merge!( 
      {:site => site.name, :site_id => site.id, :role => role.name, :role_id => role_id })
    json
  end
  
  def calculate_assignment(staff)
    self[:assigned] = staff.count { |s| s.roles.exists?(self.role_id) }
    self[:missing] = count - self[:assigned]
  end

  def to_s
    pluralize(count, role.to_s) +  ': ' + scenario_site.to_s
  end
end