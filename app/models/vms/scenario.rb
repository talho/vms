
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
  has_many :staff, :through => :site_instances
  has_many :teams, :through => :site_instances
  has_many :role_scenario_sites, :through => :site_instances
  
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
  
  def all_staff
    (staff + teams.map{ |t| t.audience.recipients.map{|ui| Vms::Staff.new(:user => ui, :scenario_site => t.scenario_site, :source => 'team', :status => 'assigned')} }).flatten.uniq
  end
  
  def execute(current_user, custom_alert = nil)
    # Find unfilled roles
    users = all_staff.map(&:user)
    h = Hash.new
    role_scenario_sites.each do |r| 
      r.calculate_assignment(users)
      r[:missing] = r.count - r[:assigned]
      
      if h.key?(r.role)
        h[r.role][:missing] += r[:missing]
        h[r.role][:rss] << r
      else
        h[r.role] = {:missing => r[:missing], :rss => [r]}
      end
    end
        
    # Find capable volunteers to fill roles
    h.each do |role, args|
      volunteers = role.volunteers.reject{|u| users.include?(u)}.take(args[:missing])
      #prioritize providing some roles to each site over filling a site
      rsss = args[:rss]
      rss = nil
      while (rss = rsss.pop) && volunteers.count > 0
        v = volunteers.pop
        users << v
        rss.scenario_site.staff.create :user => v, :status => 'assigned', :source => 'auto'
        rss[:missing] -= 1 # decrement missing
        rsss.insert(0, rss) if rss[:missing] > 0 #stick the role back on the front of the array if we still have missing roles
      end
      # Alert volunteers to ask if they can participate
      # On callbacks, select the users that can respond soonest and notify of selection and standby      
    end
    
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
      al = VmsAlert.new :title => "Scenario #{name} has been paused.", :message => custom_alert || "The scenario that you were participating in has been suspended. You may receive notification when this scenario has been resumed.", :author => current_user
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
      al = VmsAlert.new :title => "Scenario #{name} has been resumed.", :message => custom_alert || "The scenario that you have been participating in has resumed. Please reassume your normal duties.", :author => current_user
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
    al = VmsAlert.new :title => "Scenario #{name} has been stopped.", :message => custom_alert || "The scenario that you have been participating in has ended. Thank you for your participation.", :author => current_user
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
    al = VmsAlert.new :title => "Scenario #{name} has been paused.", :message => custom_alert, :author => current_user
    al.audiences << (Audience.new :users => users)
    
    al.save
  end
  handle_asynchronously :alert
end