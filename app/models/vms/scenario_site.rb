
class Vms::ScenarioSite < ActiveRecord::Base  
  set_table_name "vms_scenario_site"

  acts_as_taggable_on :qualifications

  belongs_to :site, :class_name => "Vms::Site"
  belongs_to :scenario, :class_name => "Vms::Scenario"
  belongs_to :site_admin, :class_name => "User"
  before_update :check_state_for_alert_need



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
  
  def all_staff
    (staff + teams.map{ |t| t.audience.recipients.map{|ui| Vms::Staff.new(:user => ui, :scenario_site => self, :source => 'team', :status => 'assigned')} }).flatten.uniq
  end
  
  def alert_users_of_site_deactivation
    al = VmsAlert.new :title => "Site #{site.name} deactivated", :author => scenario.users.owner, :audiences => [Audience.new :users => all_staff.map(&:user)], :scenario => scenario,
                      :message => "The site #{site.name} located at #{site.address} has been deactivated. You were assigned to that site. You will be notified when the site is reactivated."
    al.save
  end
  handle_asynchronously :alert_users_of_site_deactivation
  
  def alert_users_of_site_activation
    al = VmsAlert.new :title => "Site #{site.name} activated", :author => scenario.users.owner, :audiences => [Audience.new :users => all_staff.map(&:user)], :scenario => scenario,
                      :message => "The site #{site.name} located at #{site.address} has been activated. You are assigned to that site and should resume your duties."
    al.save
  end
  handle_asynchronously :alert_users_of_site_activation
  
  # Copy returns a new scenario_site but does not save that record.
  def copy(opts = {})
    scenario_site = Vms::ScenarioSite.new(self.attributes)
    scenario_site.attributes = opts
    
    self.inventories.each do |inv|
      scenario_site.inventories << inv.clone
    end
    
    self.role_scenario_sites.each do |rss|
      scenario_site.role_scenario_sites.build(rss.attributes)
    end
    
    self.staff.each do |stf|
      scenario_site.staff.build(stf.attributes)
    end
    
    self.teams.each do |team|
      scenario_site.teams.build(team.attributes)
    end
    
    scenario_site
  end

  def to_s
    Vms::Site.find(site_id).name  + ': ' + Vms::Scenario.find(scenario_id).name
  end

  private
  def check_state_for_alert_need
    if self.changed.include?('status') && self.scenario.executing?
      if self.status == Vms::ScenarioSite::STATES[:inactive]
        self.alert_users_of_site_deactivation
      else
        self.alert_users_of_site_activation
      end
    end
  end

end