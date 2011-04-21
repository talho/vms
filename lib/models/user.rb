require 'dispatcher'

module Vms
  Dispatcher.to_prepare do 
    ::User.class_eval do
      has_many :user_rights, :class_name => 'Vms::UserRight'
      has_many :scenarios, :class_name => 'Vms::Scenario', :through => :user_rights do
        def editable
          find(:all, :conditions => {'vms_user_rights.permission_level' => [Vms::UserRight::PERMISSIONS[:admin], Vms::UserRight::PERMISSIONS[:owner]] } )
        end
      end
      
      acts_as_taggable_on :qualifications
    end
  end
end

