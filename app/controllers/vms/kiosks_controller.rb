class Vms::KiosksController < ApplicationController
  def show
    respond_to do |format|
      format.html {
        @ssite = Vms::ScenarioSite.find(params['id'])
        render :scenario_site => @ssite, :layout => 'vms_kiosk'
      }
      format.json {
        volunteer_users = User.find(:all, :conditions => {:id =>Vms::ScenarioSite.find(params['id']).staff.map(&:user_id) }, :order => 'last_name ASC')
        volunteers = []
        volunteer_users.each do | v |
          volunteers.push({:id => v.id, :display_name => v.display_name, :email => v.email, :image => v.photo(:tiny) })
        end
        render :json=>{:volunteers => volunteers}
      }
    end
  end
  
end