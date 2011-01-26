
class Vms::ScenarioSite < ActiveRecord::Base  
  set_table_name "vms_scenario_site"

  belongs_to :site, :class_name => "Vms::Site"
  belongs_to :scenario, :class_name => "Vms::Scenario"
  STATES = {:inactive => 1, :active => 2}  
  
  def as_json (options = {})
    options[:include] = {} if options[:include].nil?
    options[:include].merge! :site => {}
    super(options)    
  end
end