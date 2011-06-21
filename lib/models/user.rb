require 'dispatcher'

module Vms
  module User
    def self.included(base)
      base.has_many :user_rights, :class_name => 'Vms::UserRight'
      base.has_many :scenarios, :class_name => 'Vms::Scenario', :through => :user_rights do
        def editable
          scoped :conditions => {'vms_user_rights.permission_level' => [Vms::UserRight::PERMISSIONS[:admin], Vms::UserRight::PERMISSIONS[:owner]] }
        end
        acts_as_taggable_on :qualifications
      end
      base.acts_as_taggable_on :qualifications
      super # make sure ActiveRecord's own .included() is called
    end
    
    def vms_admin?
      roles.exists?(:name => 'Admin', :application => 'vms')
    end
    
    def vms_volunteer?
      roles.exists?(:name => 'Volunteer', :application => 'vms')
    end

    module ClassMethods
    end
    
    def vms_scenario_sites
      Vms::ScenarioSite.find(:all, :conditions => {:site_admin_id => id}, :order => 'id DESC')
    end

    def vms_active_scenario_sites
      Vms::ScenarioSite.find(:all, :conditions => ['site_admin_id = ? AND scenario_id IN (?)', id, Vms::Scenario.active.map(&:id) ], :order => 'id DESC')
    end

    def is_vms_active_scenario_site_admin?
      vms_active_scenario_sites.count > 0
    end

    def is_vms_scenario_site_admin?
      vms_scenario_sites.count > 0
    end

    def is_vms_scenario_site_admin_for?(scenario_site)
      scenario_site.site_admin_id == id
    end
end

  Dispatcher.to_prepare do
    ::User.send(:include, Vms::User)
  end
end

