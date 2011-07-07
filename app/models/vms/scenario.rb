
class Vms::Scenario < ActiveRecord::Base  
  set_table_name "vms_scenarios"
    
  has_many :user_rights, :class_name => 'Vms::UserRight' do
    def non_owners
      scoped :conditions => {'permission_level' => [Vms::UserRight::PERMISSIONS[:reader], Vms::UserRight::PERMISSIONS[:admin]]}
    end
  end
  
  has_many :users, :through => :user_rights do
    def owner
      find(:first, :conditions => {'vms_user_rights.permission_level' => Vms::UserRight::PERMISSIONS[:owner] })
    end
  end
  
  has_many :site_instances, :class_name => "Vms::ScenarioSite" do
    def for_site(id)
      find_by_site_id(id)
    end
    def for_site_by_name(name)
      for_site(Vms::Site.find_by_name(name))
    end
  end
  has_many :sites, :through => :site_instances
  
  has_many :inventories, :through => :site_instances
  has_many :staff, :through => :site_instances, :order => 'vms_staff.id'
  has_many :teams, :through => :site_instances
  has_many :walkups, :through => :site_instances
  has_many :role_scenario_sites, :through => :site_instances, :order => 'vms_roles_scenario_sites.id'
  has_many :vms_alerts, :class_name => "VmsAlert"
  
  accepts_nested_attributes_for :user_rights, :allow_destroy => true, :reject_if => proc {|ur| ur[:permission_level]  == Vms::UserRight::PERMISSIONS[:owner]}
  
  STATES = {:template => 1, :unexecuted => 2, :executing => 3, :paused => 4, :complete => 5}
  
  validates_presence_of :name
  validates_each :user_rights, :on => :update do |record, attr, value|
    value.each do |right|
      if right.changed? && !right.new_record?
        record.errors.add "Tried to change owner" if right.permission_level_was == Vms::UserRight::PERMISSIONS[:owner]
        record.errors.add "Tried to add new owner" if right.permission_level == Vms::UserRight::PERMISSIONS[:owner]
      end
    end
  end

  STATES.each { |k,v| named_scope k, :conditions => { :state => v } }
  named_scope :active, :conditions => [ "state IN (?)", [STATES[:executing], STATES[:paused]] ]

  def to_s
    name
  end

  def template?
    state == Vms::Scenario::STATES[:template]
  end

  def in_progress?
    state == Vms::Scenario::STATES[:executing]
  end
  
  def paused?
    state == Vms::Scenario::STATES[:paused]
  end
  
  def stopped?
    state == Vms::Scenario::STATES[:complete]
  end
  
  def unexecuted?
    state == Vms::Scenario::STATES[:unexecuted]
  end
  
  def executing?
    state == Vms::Scenario::STATES[:executing]
  end

  def active?
    state == (Vms::Scenario::STATES[:executing] || Vms::Scenario::STATES[:paused] )
  end

  def all_staff
    walkups.inject(staff.uniq.to_a){|s,w| s.push(w)}
  end
  
  def clone(opts = {})
    # In this method, we're needing to do a complete clone of all of the attached values. This means that we have to copy any site_instances as new instances and all of those connections as new as well
    
    scenario = Vms::Scenario.new(self.attributes)
    scenario.attributes = opts
    scenario.created_at = scenario.updated_at = Time.now
    
    self.site_instances.each do |si|
      scenario.site_instances << si.copy # si.copy is going to copy all of the properties and associations of the site instance, but not save it
    end
    
    self.user_rights.each do |ur|
      scenario.user_rights.build(ur.attributes) # ur has no has_many associations, so we can just copy it directly
    end
    
    scenario.save!
    scenario
  end
  
  def execute(current_user)
    # Find unfilled roles
    h = Hash.new
    role_scenario_sites.each do |r| 
      r.calculate_assignment(r.scenario_site.all_staff.map(&:user))
      
      next if r[:missing] <= 0
      
      if h.key?(r.role)
        h[r.role][:missing] += r[:missing]
        h[r.role][:rss] << r
      else
        h[r.role] = {:missing => r[:missing], :rss => [r]}
      end
    end
    
    all_users = all_staff.map(&:user)
    
    all_volunteers = []
    al = VmsExecutionAlert.new :title => "Scenario #{name} is looking for volunteers", :author => current_user, :scenario => self
    # Find capable volunteers to fill roles
    vol_hash = Hash.new
    h.each do |role, args|
      volunteers = role.volunteers.reject{|u| all_users.include?(u)}
      volunteers.each do |vol|
        all_volunteers << vol unless all_volunteers.include?(vol)
        al.vms_volunteer_roles.build :volunteer => vol, :role => role
      end
    end
    
    al.audiences << (Audience.new :users => all_volunteers)
    al.save
    
    status_alert = VmsStatusAlert.default_alert(:title => "Scenario #{name} is now executing", :message => "Scenario #{name} is now executing.", 
                                                :audiences => [Audience.new :users => all_users], :scenario => self, :author => current_user)
    status_alert.save
  end
  handle_asynchronously :execute
  
  def pause(current_user, alert = false, custom_alert = nil, custom_audience = nil)
    if alert
      users = []
      if custom_audience
        custom_audience.each { |a| users << User.find(a.to_i) }
      else
        users = all_staff.map(&:user)
      end

      # Alert users for the scenario that the execution has been paused.
      al = VmsAlert.new :title => "Scenario #{name} has been paused.", :message => custom_alert || "The scenario that you were participating in has been suspended. You may receive notification when this scenario has been resumed.", 
           :author => current_user, :scenario => self
      al.audiences << (Audience.new :users => users)

      al.save
    end
  end
  handle_asynchronously :pause
  
  def resume(current_user, alert = false, custom_alert = nil, custom_audience = nil)
    if alert
      users = []
      if custom_audience
        custom_audience.each { |a| users << User.find(a.to_i)}
      else
        users = all_staff.map(&:user)
      end
      
      # Alert users for the scenario that the execution has been resumed.
      al = VmsAlert.new :title => "Scenario #{name} has been resumed.", :message => custom_alert || "The scenario that you have been participating in has resumed. Please reassume your normal duties.", :author => current_user, :scenario => self
      al.audiences << (Audience.new :users => users)
      
      al.save
    end
  end
  handle_asynchronously :resume
  
  def stop(current_user, custom_alert = nil, custom_audience = nil)
    users = []
    if custom_audience
      custom_audience.each { |a| users << User.find(a.to_i) }
    else
      users = all_staff.map(&:user)
    end
    
    # Alert users that the scenario execution is complete and they can go home
    al = VmsAlert.new :title => "Scenario #{name} has been stopped.", :message => custom_alert || "The scenario that you have been participating in has ended. Thank you for your participation.", :author => current_user, :scenario => self
    al.audiences << (Audience.new :users => users)
    
    al.save
  end
  handle_asynchronously :stop
  
  def alert(current_user, custom_alert = nil, custom_audience = nil)
    return if custom_alert.nil?
    
    users = []
    if custom_audience
      custom_audience.each { |a| users << User.find(a.to_i) }
    else
      users = all_staff.map(&:user)
    end
    
    # Send a custom alert to all volunteers or a subset thereof for a certain scenario.
    al = VmsAlert.new :title => "Custom Alert", :message => custom_alert, :author => current_user, :scenario => self
    al.audiences << (Audience.new :users => users)
    
    al.save
  end
  handle_asynchronously :alert
  
  def process_alert_responses
    require 'vendor/plugins/backgroundrb/server/lib/bdrb_server_helper.rb'
    require 'vendor/plugins/backgroundrb/server/lib/meta_worker.rb'
    require 'vendor/plugins/vms/lib/workers/watch_for_vms_execution_alert_responses_worker.rb'
    WatchForVmsExecutionAlertResponsesWorker.new.query
  end
end