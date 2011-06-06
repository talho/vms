class Vms::KiosksController < ApplicationController
  skip_before_filter :login_required
  before_filter :vms_session_required, :except => [:registered_checkin, :walkup_checkin]
  before_filter :vms_site_admin_required, :except => [:index, :registered_checkin, :walkup_checkin]

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
        render :json=>{ :volunteers => volunteers.uniq }
      }
    end
  end

  def index
    @user = User.find(session[:vms_user_id])
    @ssites = @user.vms_active_scenario_sites
    render :layout => 'vms_kiosk'
  end

  def registered_checkin
    if params['walkup_id']
      walkup = Vms::Walkup.find(params['walkup_id'])
      walkup.update_attributes(:checked_in => !walkup.checked_in?)
      respond_to do |format|
        format.json{ render :json=> {:success => true} }
      end
    else
      @ssite = Vms::ScenarioSite.find(params['scenario_site_id'])
      @user = User.authenticate(params['email'], params['password'])
      if @user.nil? || @ssite.nil?
        success = false
      else
        staff_record = @ssite.staff.find_or_create_by_user_id(@user.id)
        # remove any staff assignments for this user on other ssites in this scenario
        @ssite.scenario.staff.find(:all, :conditions=>['scenario_site_id != ? AND user_id = ?',@ssite.id, @user.id]).each{ |s| s.destroy }
        staff_record.checked_in = !staff_record.checked_in?
        success = staff_record.save!
      end
      respond_to do |format|
        format.json{ render :json=> {:success => success} }
      end
    end
  end

  def walkup_checkin
    @ssite = Vms::ScenarioSite.find(params['scenario_site_id'])
    if params['walkup_new_account']
      #TODO: detect existing email and prompt for normal checkin
      #TODO: catch validation errors and return them to EXT
      begin
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

  def vms_session_required
    begin
      if User.find(session[:vms_user_id])
        session.delete(:user_id) if session[:user_id]   # nuke the Phin session when kiosk stuff is happening - we don't want active phin sessions when kiosks might be unattended
        return true
      end
    rescue
      respond_to do |format|
          format.html {
            flash[:error] = "You must sign in to access this page"
            redirect_to vms_session_new_path
          }
      end
    end
  end

  def vms_site_admin_required
    user = User.find(session[:vms_user_id])
    unless user.is_vms_scenario_site_admin? && user.is_vms_scenario_site_admin_for?( Vms::ScenarioSite.find(params['id']) )
      respond_to do |format|
          format.html {
            flash[:error] = "You are not an administrator for that Scenario and Site"
            redirect_to kiosk_index_path
          }
      end
    end
  end
  
end
