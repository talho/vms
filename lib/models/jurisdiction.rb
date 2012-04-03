require 'action_controller/deprecated/dispatcher'

module Vms
  module Jurisdiction
    def self.included(base)
      base.scope :vms_admin, lambda{{:include => :role_memberships,
        :conditions => { :role_memberships => { :role_id => [::Role.admin('vms').id] } }}}
      base.scope :vms_volunteer, lambda{{:include => :role_memberships,
        :conditions => { :role_memberships => { :role_id => [::Role.find_by_name_and_application('Volunteer', 'vms').id] } }}}
      super
    end
    
    def vms_volunteers
      users.with_role(::Role.find_by_name_and_application('Volunteer', 'vms'))
    end
  end
  
  ActionController::Dispatcher.to_prepare do
    ::Jurisdiction.send(:include, Vms::Jurisdiction)
  end
end

