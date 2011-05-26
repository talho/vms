class User < ActiveRecord::Base
  def vms_active_scenario_sites
    Vms::ScenarioSite.find(:all, :conditions => ["site_admin_id = ? AND status = ? AND (select status from vms_scenarios where scenario_id = scenario_id) = ?", 
                                                 id, Vms::ScenarioSite::STATES[:active],Vms::Scenario::STATES[:executed] ])
  end

  def is_vms_active_scenario_site_admin?
    vms_active_scenario_sites.count > 0
  end

  def vms_scenario_sites
    Vms::ScenarioSite.find(:all, :conditions => {:site_admin_id => id})
  end

  def is_vms_scenario_site_admin?
    vms_scenario_sites.count > 0
  end

  def is_vms_scenario_site_admin_for?(scenario_site)
    scenario_site.site_admin_id == id
  end


end