
class Vms::ScenariosController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    conditions = params[:state] ? {:state => params[:state].map{|x| x.to_i} } : {}
    @scenarios = current_user.scenarios.find(:all, :conditions => conditions, :order=> 'created_at', :include => [:user_rights, :site_instances]).paginate(:page => ( (params[:start]||0).to_i/(params[:limit]||10).to_i ) + 1, :per_page => params[:limit] || 10)
    @scenarios.each do |sc|
      perm_lvl = sc.user_rights.find_by_user_id(current_user).permission_level
      sc[:can_admin] =  perm_lvl == Vms::UserRight::PERMISSIONS[:owner] || perm_lvl == Vms::UserRight::PERMISSIONS[:admin]
      sc[:is_owner] = perm_lvl == Vms::UserRight::PERMISSIONS[:owner]
      sc[:user_rights] = sc.user_rights
      sc[:site_instances] = sc.site_instances
    end
    respond_to do |format|
      format.json {render :json => {:scenarios => @scenarios.as_json, :total => @scenarios.total_entries } }
    end
  end  
  
  def show
    @scenario = current_user.scenarios.find(params[:id], :include => {:user_rights => [], :site_instances => [:site], :inventories => [], :staff => [], :teams => [], :role_scenario_sites => []})
    perm_lvl = @scenario.user_rights.find_by_user_id(current_user).permission_level
    @scenario[:can_admin] = perm_lvl == Vms::UserRight::PERMISSIONS[:owner] || perm_lvl == Vms::UserRight::PERMISSIONS[:admin]
    @scenario[:site_instances] = @scenario.site_instances.as_json
    @scenario[:inventories] = @scenario.inventories.as_json
    @scenario[:all_staff] = @scenario.all_staff.as_json
    @scenario[:teams] = @scenario.teams.as_json
    @scenario[:roles] = @scenario.role_scenario_sites.as_json
    @scenario[:qualifications] = @scenario.site_instances.map(&:complete_qualification_list).flatten
    respond_to do |format|
      unless @scenario.nil?
        json = @scenario.as_json
        json[:type] = 'event'
        format.json {render :json => json}
      else
        format.json {render :json => {:msg => 'You do not have permission to open this scenario'}, :status => 404 }
      end
    end
  end
  
  def new
    respond_to do |format|
      format.json {render :json => {} }
    end
  end
  
  def create
    unless current_user.vms_admin?
      respond_to do |format|
        format.json {render :json => {:msg => 'You are not a VMS admin, you cannot create scenarios'}, :status => 404}
      end
      return
    end
    
    tmpl = params[:template] == true || params[:template] == 'true' || false
    
    params[:scenario][:state] = tmpl ? Vms::Scenario::STATES[:template] : Vms::Scenario::STATES[:unexecuted]
    @scenario = Vms::Scenario.new(params[:scenario])
    @scenario.user_rights.build(:user_id => current_user.id, :permission_level => Vms::UserRight::PERMISSIONS[:owner])
    if @scenario.save
      respond_to do |format|
        format.json {render :json => {:scenario => @scenario.as_json, :success => true} }
      end
    else
      respond_to do |format|
        format.json {render :json => {:msg => 'Error creating the scenario', :errors => @scenario.errors }, :status => 406 }
      end
    end
  end
  
  def edit
    unless current_user.vms_admin?
      respond_to do |format|
        format.json {render :json => {:msg => 'You are not a VMS admin, you cannot modify scenarios'}, :status => 404}
      end
      return
    end
    
    @scenario = current_user.scenarios.editable.find(params[:id], :include => {:user_rights => [:user]})
    respond_to do |format|
      unless @scenario.nil?
        format.json {render :json => {:scenario => @scenario.as_json, :user_rights => @scenario.user_rights.non_owners.as_json }}
      else
        format.json {render :json => {:msg => 'You do not have permission to edit this scenario'}, :status => 404 }
      end
    end
  end
  
  def update
    unless current_user.vms_admin?
      respond_to do |format|
        format.json {render :json => {:msg => 'You are not a VMS admin, you cannot modify scenarios'}, :status => 404}
      end
      return
    end
    
    @scenario = current_user.scenarios.editable.find(params[:id])
    if @scenario.update_attributes(params[:scenario])
      respond_to do |format|
        format.json {render :json => {:scenario => @scenario.as_json, :success => true} }
      end
    else
      respond_to do |format|
        format.json {render :json => {:msg => 'Error creating the scenario', :errors => @scenario.errors }, :status => 406 }
      end
    end    
  end
  
  def destroy
    unless current_user.vms_admin?
      respond_to do |format|
        format.json {render :json => {:msg => 'You are not a VMS admin, you cannot delete scenarios'}, :status => 404}
      end
      return
    end
    
    @scenario = current_user.scenarios.editable.find(params[:id])
    respond_to do |format|
      if @scenario.destroy
        format.json {render :json => {:success => true} }
      else
        format.json {render :json => {:success => false, :errors => @scenario.errors}, :status => 406}
      end
    end
  end
  
  ## Split the execute action off into its own space because of the specialized logic that will need to go into running the first execution,
  #  though most of that specialized logic will go into delayed jobs
  def execute
    @scenario = current_user.scenarios.editable.find(params[:id])
    
    current_state = @scenario.state
    unless @scenario.template? || @scenario.unexecuted? || @scenario.paused? # you can only execute unexecuted or paused scenarios
      respond_to do |format|
        format.json {render :json => {:msg => "You cannot execute a scenario of state " + Vms::Scenario::STATES.invert[@scenario].to_s + ".", :success => false}, :status => 400}
      end
      return
    end
    
    if @scenario.template?
      @scenario = @scenario.deep_clone({:state => Vms::Scenario::STATES[:executing]})
    else
      @scenario.update_attributes :state => Vms::Scenario::STATES[:executing]
    end
    
    if current_state == Vms::Scenario::STATES[:paused]
      custom_msg = params[:custom_msg].blank? ? nil : params[:custom_msg]
      aud = (params[:custom_aud] && !params[:custom_aud].blank? && params[:custom_aud].first && !params[:custom_aud].first.blank?) ? params[:custom_aud] : nil
      @scenario.resume(current_user, params[:send_msg], custom_msg, aud)
    else
      @scenario.execute(current_user)
    end

    respond_to do |format|
      format.json {render :json => {:success => true, :scenario => @scenario} }
    end
  end
  
  def pause
    @scenario = current_user.scenarios.editable.find(params[:id])
    unless @scenario.in_progress?
      respond_to do |format|
        format.json {render :json => {:msg => "You can only pause an executing scenario. Your scenario is " + Vms::Scenario::STATES.invert[@scenario].to_s + ".", :success => false}, :status => 400}
      end
      return
    end
    @scenario.update_attributes :state => Vms::Scenario::STATES[:paused]
    
    custom_msg = params[:custom_msg].blank? ? nil : params[:custom_msg]
    aud = (params[:custom_aud] && !params[:custom_aud].blank? && params[:custom_aud].first && !params[:custom_aud].first.blank?) ? params[:custom_aud] : nil 
    @scenario.pause(current_user, params[:send_msg], custom_msg, aud)
    
    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end
  
  def stop
    @scenario = current_user.scenarios.editable.find(params[:id])
    
    unless @scenario.executing? || @scenario.paused? # you can only execute unexecuted or paused scenarios
      respond_to do |format|
        format.json {render :json => {:msg => "You cannot stop a scenario of state " + Vms::Scenario::STATES.invert[@scenario].to_s + ".", :success => false}, :status => 400}
      end
      return
    end
    @scenario.update_attributes :state => Vms::Scenario::STATES[:complete]
    
    custom_msg = params[:custom_msg].blank? ? nil : params[:custom_msg]
    aud = (params[:custom_aud] && !params[:custom_aud].blank? && params[:custom_aud].first && !params[:custom_aud].first.blank?) ? params[:custom_aud] : nil
    @scenario.stop(current_user, custom_msg, aud)
    
    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end
  
  def alert
    @scenario = current_user.scenarios.editable.find(params[:id])
    
    custom_msg = params[:custom_msg].blank? ? nil : params[:custom_msg]
    aud = (params[:custom_aud] && !params[:custom_aud].blank? && params[:custom_aud].first && !params[:custom_aud].first.blank?) ? params[:custom_aud] : nil
    @scenario.alert(current_user, custom_msg, aud)
    
    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end
  
  def copy
    @scenario = current_user.scenarios.editable.find(params[:id])
    
    respond_to do |format|
      format.json {render :json => {:success => false}, :status => 400 }
    end if params[:state].to_i < 1 || params[:state].to_i > 5 # we want to fail this transaction if they didn't provide a valid state
    
    @scenario = @scenario.deep_clone({:state => params[:state].to_i})
    
    respond_to do |format|
      format.json {render :json => {:success => true, :scenario => @scenario} }
    end
  end
end