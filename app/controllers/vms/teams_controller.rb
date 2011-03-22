class Vms::TeamsController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required, :change_include_root
  before_filter :initialize_scenario
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
    team.audience = Audience.new params[:team][:audience]
    team.audience.scope = "Team"
    team.audience.owner = current_user
    aud = nil
    if params[:save_template] == "true" && (par_aud.nil? || Group::SCOPE.include?(par_aud.scope)) #do this if we're saving a template and the parent template is null or the parent audience is a group (and not a team)
      aud = Audience.new team.audience.attributes
      aud.type = "Group"
      aud.sub_audiences = [team.audience]
    elsif params[:save_template] == "false" && !par_aud.nil?
      team.audience.parent_audiences << par_aud
    end
    
    
    respond_to do |format|
      if @scenario_site.save && (aud.nil? || aud.save)
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
    
    #build team. params[:team] should contain team[audience][name] and team[audience][users]
    if params[:team][:audience][:user_ids].nil?
      params[:team][:audience][:user_ids] = []
    end
    
    debugger
    aud = @team.audience
    aud.attributes = params[:team][:audience]
    
    #wokay, so here we want to see what the parent is, then we're going to see if it's a "team" and if it's a team, we'll go ahead and update it.
    par_aud = @team.audience.parent_audiences.first
    if !par_aud.nil? && par_aud.scope == 'Team'
      par_aud.attributes = params[:team][:audience]
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