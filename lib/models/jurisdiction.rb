require 'dispatcher'

module Vms
  module Jurisdiction
    def self.included(base)
      base.named_scope :vms_admin, lambda{{:include => :role_memberships,
        :conditions => { :role_memberships => { :role_id => [::Role.admin('vms').id] } }}}
      base.named_scope :vms_volunteer, lambda{{:include => :role_memberships,
        :conditions => { :role_memberships => { :role_id => [::Role.find_by_name_and_application('Volunteer', 'vms').id] } }}}
      super
    end
    
    def vms_volunteers
      users.with_role(::Role.find_by_name_and_application('Volunteer', 'vms'))
    end
  end
  
  Dispatcher.to_prepare do
    ::Jurisdiction.send(:include, Vms::Jurisdiction)
  end
end

