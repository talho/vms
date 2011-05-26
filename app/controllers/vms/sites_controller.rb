class Vms::SitesController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :initialize_scenario, :only => [:index, :show, :existing]
  before_filter :initialize_protected_scenario, :only => [:create, :edit, :update, :destroy]
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    @site_instances = @scenario.site_instances
    respond_to do |format|
      format.json {render :json => {:sites => @site_instances.as_json} }
    end
  end  
  
  def show
    debugger
    @site = @scenario.site_instances.find_by_site_id(params[:id], :include => {:teams => {:audience => [:users]}, :staff => {:user => [:roles]}, :role_scenario_sites => [:role], :inventories => {:item_instances => {:item => :item_category} } })
    # here we need to work with calculating full lists of 1) the staff assigned to the site, both manually and automatically (automatic assignment in progress)
    staff = @site.staff.map {|s| s.user[:source] = 'manual'; s.user[:staff_id] = s.id; s.user }
    # 2) the roles assigned to the site and which staff members are filling those roles. this could become interesting because, when a user is manually assigned, we have to decide if he's filling 1 or many roles
    @site.role_scenario_sites.each { |r| r.calculate_assignment(staff) }
    # 3) any calculations that need to be done on inventory items
    # I think that it is best to push the calculations back to the models so we can reuse them elsewhere
    respond_to do |format|
      format.json {render :json => { :site => @site.as_json, :roles => @site.role_scenario_sites.as_json,
                                     :items => @site.inventories.map(&:item_instances).flatten.as_json, :staff => Vms::Staff.users_as_staff_json(staff) } }
    end
  end
  
  def new
   
  end
  
  def create
    @site = Vms::Site.new(params[:site])
    @site.scenario_instances.build(:scenario => @scenario, :status => params[:status].nil? ? Vms::ScenarioSite::STATES[:inactive] : params[:status].to_i)
    respond_to do |format|
      if @site.save!
        format.json {render :json => {:site => @site.scenario_instances.find_by_scenario_id(@scenario.id), :success => true} }
      else
        format.json {render :json => {:errors => @site.errors, :success => false}, :status => 400 }
      end
    end
  end
  
  def edit
    @site = Vms::Site.find(params[:id])
    respond_to do |format|
      format.json {render :json => {:site => @site.as_json } }
    end
  end
  
  def update
    @site = Vms::Site.find(params[:id])
    @site.update_attributes params[:site] unless params[:site].nil? || params[:site].blank?
    @scenario_instance = @site.scenario_instances.find_by_scenario_id(@scenario.id)
    @scenario_instance = @site.scenario_instances.build :scenario => @scenario if @scenario_instance.nil?
    @scenario_instance.status = params[:status].to_i unless params[:status].nil? || params[:status].blank?
    respond_to do |format|
      if @scenario_instance.save! && @site.save!
        format.json {render :json => {:site => @site.scenario_instances.find_by_scenario_id(@scenario.id), :success => true} }
      else
        format.json {render :json => {:errors => @site.errors, :instance_errors => @scenario_instance.errors, :success => false}, :status => 400 }
      end
    end
  end
  
  def destroy
    @site = @scenario.sites.find(params[:id])
    permanent = params[:permanent] == 'true' && @site.scenario_instances.length == 1 && @site.scenario_instances.first.scenario == @scenario
    if permanent
      success = @site.destroy
    else
      @scenario_instance = @site.scenario_instances.find_by_scenario_id(@scenario.id)
      success = @scenario_instance.destroy
    end
    
    respond_to do |format|
      if success
        format.json {render :json => {:success => true} }
      else
        format.json {render :json => {:success => false, :errors => @scenario.errors}, :status => 406}
      end
    end
  end
  
  def existing
    @sites = Vms::Site.find(:all, :conditions => ["name like ?", '%' + params[:name] + '%']) - @scenario.sites
    
    respond_to do |format|
      format.json {render :json => {:sites => @sites} }
    end    
  end
  
end