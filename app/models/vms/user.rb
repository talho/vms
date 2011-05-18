class User < ActiveRecord::Base
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