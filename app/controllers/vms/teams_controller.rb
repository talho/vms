class Vms::TeamsController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required, :change_include_root
  before_filter :initialize_scenario, :only => [:index, :show]
  before_filter :initialize_protected_scenario, :only => [:create, :edit, :update, :destroy]
  after_filter :change_include_root_back
  
  def index
    @teams = @scenario.teams.find(:all, :include => {:audience => [:users]})
    respond_to do |format|
      format.json { render :json => @teams.as_json }
    end
  end
  
  def show
    @team = @scenario.site_instances.for_site(params[:vms_site_id]).teams.find(params[:id], :include => {:audience => [:users]})
    
    @team[:users] = []
    @team.audience.users.each do |u|        
      @team[:users] << {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                        :tip => render_to_string(:partial => 'searches/extra.json', :locals => {:user => u})}
    end
    
    respond_to do |format|
      format.json {render :json => @team.as_json}
    end
  end
  
  def new
    respond_to do |format|
      format.json {render :json => {}}
    end
  end
  
  def create
    @scenario_site = @scenario.site_instances.for_site(params[:vms_site_id])
    
    par_aud = Audience.find(params[:audience_parent_id], :include => [:roles, :jurisdictions, :sub_audiences]) unless params[:audience_parent_id].nil?
    
    unless par_aud.nil?
      #handle possibly reassigning the team "created" to a different site here
    end
    
    #build team. params[:team] should contain team[audience][name] and team[audience][users]
    team = @scenario_site.teams.build
    team.audience = Audience.new
    team.audience.build params[:team][:audience]
    team.audience.scope = "Team"
    team.audience.owner = current_user

    aud = nil
    if params[:save_template] == "true" && (par_aud.nil? || Group::SCOPE.include?(par_aud.scope)) #do this if we're saving a template and the parent template is null or the parent audience is a group (and not a team)
      aud = Audience.new team.audience.attributes
      aud.user_ids = team.audience.user_ids
      aud.type = "Group"
      aud.sub_audiences = [team.audience]
    elsif params[:save_template] == "false" && !par_aud.nil?
      team.audience.parent_audiences << par_aud
    end
      
    respond_to do |format|
      if @scenario_site.save && (aud.nil? || aud.save)
        team.audience.recipients.each do | user |
          @staff = @scenario_site.staff.find_or_create_by_user_id_and_scenario_site_id( user.id, @scenario_site.id)
          @staff.update_attributes({:source => 'team'})
        end
        format.json {render :json => {:success => true} }
      else
        format.json {render :json => {:success => false, :errors => @scenario_site.errors, :aud_errors => aud.nil? ? [] : aud.errors}, :status => 400 }
      end
    end
  end
  
  def edit
    show()
  end
  
  def update
    @team = @scenario.site_instances.for_site(params[:vms_site_id]).teams.find(params[:id])
    @scenario_site = @scenario.site_instances.find_by_site_id_and_scenario_id(params[:site_id], params[:vms_scenario_id])

    unless params[:team].nil? || params[:team][:audience].nil?
      #build team. params[:team] should contain team[audience][name] and team[audience][users]
      if params[:team][:audience][:user_ids].nil?
        params[:team][:audience][:user_ids] = []
      end    
      @team.audience.attributes = params[:team][:audience]
    end
    
    unless params[:site_id].nil? || @team.scenario_site == @scenario_site
      @team.audience.recipients.each do | u |
        #remove any members of this team from other sites staffs if they are not checked in
        @scenario.staff.find(:all, :conditions=>['scenario_site_id != ? AND user_id = ? AND checked_in = ?',@scenario_site.id, u.id, false]).each{ |s| s.destroy }
        #add all team members to staff on target ScenarioSite
        newstaff = @scenario_site.staff.find_or_create_by_user_id(u.id)
        newstaff.update_attributes({:status => 'assigned', :source => 'team'})
      end
      @team.scenario_site = @scenario_site
    end
    
    respond_to do |format|
      if @team.save
        format.json {render :json => {:success => true} }
      else
        format.json {render :json => {:success => false, :errors => @scenario_site.errors}, :status => 400 }
      end
    end
  end
    
  def destroy
    @team = @scenario.site_instances.for_site(params[:vms_site_id]).teams.find(params[:id])
    
    respond_to do |format|
      if @team.destroy
        format.json {render :json => {:success => true } }
      else
        format.json {render :json => {:success => false, :errors => @team.errors }, :status => 400}
      end
    end
  end
end