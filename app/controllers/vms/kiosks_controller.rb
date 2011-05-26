class Vms::KiosksController < ApplicationController
  before_filter :vms_kiosk_session_required, :except => [:registered_checkin, :walkup_checkin]
  
  def show
    @ssite = Vms::ScenarioSite.find(params['id'])
    respond_to do |format|
      format.html {
        render :scenario_site => @ssite, :layout => 'vms_kiosk'
      }
      format.json {
        volunteers = []
        @ssite.staff.sort{|a,b| a.user.last_name<=>b.user.last_name}.each do | s |
          volunteers.push({
            :id => s.user.id,:display_name => s.user.display_name,:email => s.user.email,:image => s.user.photo(:tiny), :type => 'registered',
            :checked_in => s.checked_in, :scenario_site_admin => @ssite.site_admin == s.user
          })
        end
        @ssite.walkups.sort{|a,b| a.last_name<=>b.last_name}.each do | w |
          volunteers.push({
            :id => w.id, :display_name => w.first_name + ' ' + w.last_name,:email => nil,:image => '/stylesheets/vms/images/walkup-icon.png',:checked_in => w.checked_in, :type => 'walkup'
          })
        end
        render :json=>{:volunteers => volunteers.uniq}
      }
    end
  end

  def registered_checkin
    success = false
    if params['walkup_signout']
      walkup = Vms::Walkup.find(params['walkup_id'])
      walkup.update_attributes(:checked_in => !walkup.checked_in?)
      success = true
      respond_to do |format|
        format.json{ render :json=> {:success => success} }
      end
    else
      @ssite = Vms::ScenarioSite.find(params['scenario_site_id'])
      @user = User.authenticate(params['email'], params['password'])
      unless @user.nil? || @ssite.nil?
        staff_record = @ssite.scenario.staff.find_or_create_by_user_id(@user.id)
        # if they're checking in/out of their current ssite, invert checked_in.  otherwise, check them in (to a new ssite)
        staff_record.checked_in = staff_record.scenario_site == @ssite ? !staff_record.checked_in? : true
        staff_record.scenario_site = @ssite
        success = true if staff_record.save!
      end
      respond_to do |format|
        format.json{ render :json=> {:success => success} }
      end
    end
  end

  def walkup_checkin
    @ssite = Vms::ScenarioSite.find(params['scenario_site_id'])
    if params['walkup_new_account']
      #TODO: catch validation errors and return them to EXT
      begin
        debugger
        @user = User.create!(:first_name => params['walkup_first_name'], :last_name => params['walkup_last_name'], :display_name => params['walkup_first_name'] + ' ' + params['walkup_last_name'],
                             :email => params['walkup_email'], :password => params['walkup_password'], :password_confirm => params['walkup_password_confirm'])
        Vms::Staff.create(:scenario_site_id => @ssite.id, :user_id => @user.id, :status=> 'unassigned', :checked_in => true)
        success = true
      rescue
        success = false
      end
    else
      begin
        Vms::Walkup.create(:first_name=>params['walkup_first_name'], :last_name=>params['walkup_last_name'], :email => params['walkup_email'], :scenario_site_id=> @ssite.id, :checked_in => true)
        success = true
      rescue
        success = false
      end
    end
    respond_to do |format|
      format.json{ render :json=> {:success => success} }
    end
  end

  protected

  def vms_kiosk_session_required
    unless current_user.is_vms_scenario_site_admin? && current_user.is_vms_scenario_site_admin_for?( Vms::ScenarioSite.find(params['id']) )
      respond_to do |format|
          format.html {
            flash[:error] = "You are not an administrator for that Scenario and Site"
            redirect_to ext_path
          }
      end
    end
  end
  
end
