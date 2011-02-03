class Vms::SitesController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    @scenario = Vms::Scenario.find(params[:vms_scenario_id])
    @site_instances = @scenario.site_instances
    respond_to do |format|
      format.json {render :json => {:sites => @site_instances.as_json} }
    end
  end  
  
  def show
    @site = Vms::Site.find(params[:id])
    respond_to do |format|
      format.json {render :json => {:site => @site.as_json } }
    end
  end
  
  def new
   
  end
  
  def create
    @scenario = Vms::Scenario.find(params[:vms_scenario_id])
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
    
  end
  
  def update
    @scenario = Vms::Scenario.find(params[:vms_scenario_id])
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
    @scenario = Vms::Scenario.find(params[:vms_scenario_id])    
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
    @scenario = Vms::Scenario.find(params[:vms_scenario_id])
    @sites = Vms::Site.find(:all, :conditions => ["name like ?", '%' + params[:name] + '%']) - @scenario.sites
    
    respond_to do |format|
      format.json {render :json => {:sites => @sites} }
    end    
  end
end