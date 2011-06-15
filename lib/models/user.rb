require 'dispatcher'

module Vms
  module User
    def self.included(base)
      base.has_many :user_rights, :class_name => 'Vms::UserRight'
      base.has_many :scenarios, :class_name => 'Vms::Scenario', :through => :user_rights do
        def editable
          scoped :conditions => {'vms_user_rights.permission_level' => [Vms::UserRight::PERMISSIONS[:admin], Vms::UserRight::PERMISSIONS[:owner]] } 
        end
      end
      
      base.acts_as_taggable_on :qualifications
      
      super
    end
    
    def vms_admin?
      roles.exists?(:name => 'Admin', :application => 'vms')
    end
    
    def vms_volunteer?
      roles.exists?(:name => 'Volunteer', :application => 'vms')
    end
  end
  Dispatcher.to_prepare do
    ::User.send(:include, Vms::User)
  end
end

