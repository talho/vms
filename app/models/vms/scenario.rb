
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
  
  STATES = {:template => 1, :unexecuted => 2, :executed => 3}
  
  validates_presence_of :name
  validates_each :user_rights, :on => :update do |record, attr, value|
    value.each do |right|
      if right.changed? && !right.new_record?
        record.errors.add "Tried to change owner" if right.permission_level_was == Vms::UserRight::PERMISSIONS[:owner]
        record.errors.add "Tried to add new owner" if right.permission_level == Vms::UserRight::PERMISSIONS[:owner]
      end
    end
  end

  named_scope :active, lambda { |scenario| { :conditions => [ "state IN (?)", [STATES[:executed], STATES[:paused]] ] } }
  
  def to_s
    name
  end
  
end