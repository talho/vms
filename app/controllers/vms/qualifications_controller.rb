class Vms::QualificationsController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required
  before_filter :initialize_scenario, :only => [:index]
  before_filter :initialize_protected_scenario, :only => [:create, :update, :destroy]
  
  def index
    @si = @scenario.site_instances.all(:include => { :site => [], :role_scenario_sites => :role })
    tags = []
    
    @si.each do |si|
      tags << si.qualification_list.map { |q| {:name => q, :site_id => si.site_id, :site => si.site.name} }
      tags << si.role_scenario_sites.map { |r| r.qualification_list.map { |q| {:name => q, :role => r.role.name, :role_id => r.role_id, :site_id => si.site_id, :site => si.site.name} } }
    end
    
    tags.flatten!
    
    respond_to do |format|
      format.json {render :json => tags.as_json}
    end
  end
    
  def create
    @si = @scenario.site_instances.for_site(Vms::Site.find(params[:vms_site_id]))
    if params[:role_id].nil?
      v = @si
    else
      v = @si.role_scenario_sites.find_by_role_id(params[:role_id])      
    end
    
    v.qualification_list << params[:qualification]
    
    respond_to do |format|
      if v.save
        format.json { render :json => {:success => true} }
      else
        format.json { render :json => {:success => false, :errors => v.errors }, :status => 400 }
      end
    end    
  end
  
  def update
    @si = @scenario.site_instances.for_site(Vms::Site.find(params[:vms_site_id]))
    if params[:original_role_id].nil?
      v = @si
    else
      v = @si.role_scenario_sites.find_by_role_id(params[:original_role_id])
    end
    v.qualification_list.remove(params[:original_qualification])
        
    if params[:role_id].nil?
      @si.qualification_list << params[:qualification]
    else
      @rss = @si.role_scenario_sites.find_by_role_id(params[:role_id])
      @rss.qualification_list << params[:qualification]
    end
    
    respond_to do |format|
      if v.save && @si.save && (@rss.nil? || @rss.save )
        format.json { render :json => {:success => true} }
      else
        format.json { render :json => {:success => false, :errors => @si.errors, :original_errors => v.errors, :role_errors => @rss.nil? ? [] : @rss.errors }, :status => 400 }
      end
    end    
  end
  
  def destroy
    @si = @scenario.site_instances.for_site(Vms::Site.find(params[:vms_site_id]))
    if params[:role_id].nil?
      v = @si
    else
      v = @si.role_scenario_sites.find_by_role_id(params[:role_id])
    end
    v.qualification_list.remove(params[:qualification])
        
    respond_to do |format|
      if v.save
        format.json { render :json => {:success => true} }
      else
        format.json { render :json => {:success => false, :errors => v.errors }, :status => 400 }
      end
    end
  end
  
  def list
    filter = '%' + (params[:query] || '') + '%'
    opts = {:conditions => ["name LIKE ?", filter.downcase]}
    tags = (User.tag_counts_on(:qualifications, opts) + Vms::ScenarioSite.tag_counts_on(:qualifications, opts) + Vms::RoleScenarioSite.tag_counts_on(:qualifications, opts)).uniq
    
    respond_to do |format|
      format.json { render :json => tags.as_json }
    end
  end
end