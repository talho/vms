class User < ActiveRecord::Base
  def vms_active_sites
    Vms::ScenarioSite.find(:all, :conditions => ["site_admin_id = ? AND status = ? AND (select status from vms_scenarios where scenario_id = scenario_id) = ?", 
                                                 id, Vms::ScenarioSite::STATES[:active],Vms::Scenario::STATES[:executed] ])
  end

  def is_vms_active_site_admin?
    vms_active_sites.count > 0
  end

  def vms_sites
    Vms::ScenarioSite.find(:all, :conditions => {:site_admin_id => id})
  end
  
  def is_vms_site_admin?
    vms_sites.count > 0
  end
end