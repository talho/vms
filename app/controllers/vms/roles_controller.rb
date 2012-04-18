class Vms::RolesController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required
  before_filter :initialize_scenario, :only => [:index, :show]
  before_filter :initialize_protected_scenario, :only => [:update]
  
  def index
    @instances = @scenario.site_instances.find(:all, :include => {:role_scenario_sites => [:role, :site]})
    @roles = @instances.map(&:role_scenario_sites).flatten
    respond_to do |format|
      format.json {render :json => @roles.as_json }
    end
  end
  
  def show
    @site_instance = @scenario.site_instances.for_site(params[:site_id])
    respond_to do |format|
      format.json {render :json => @site_instance.role_scenario_sites.find(:all, :include => [:role , :site]).as_json }
    end
  end
  
  def update
    @site_instance = @scenario.site_instances.first( {:conditions => {:site_id => params[:site_id]}, :include => [:role_scenario_sites] })
    
    roles = JSON.parse(params[:roles])
    
    # pull out new, updated, and deleted roles from params
    new_roles = roles.select{|role| role['status'] == 'new'}
    updated_roles = roles.select{|role| role['status'] == 'updated'}
    deleted_roles = roles.select{|role| role['status'] == 'deleted'}
    
    rss = @site_instance.role_scenario_sites
    
    #delete existing roles
    deleted_roles.each do |role|
      db_role = rss[rss.index{ |r| r.id === role['id']}]
      db_role.mark_for_destruction
    end
    
    #create new roles
    new_roles.each do |role|
      role.delete('status')
      @site_instance.role_scenario_sites.build(role)
    end
    
    #update existing roles
    updated_roles.each do |role|
      role.delete('status')
      db_role = rss[rss.index{ |r| r.id === role['id']}]
      db_role.attributes = role
    end
    
    
    respond_to do |format|
      if @site_instance.save
        format.json {render :json => {:success => true} }
      else
        format.json {render :json => {:success => false, :errors => @site_instance.errors}, :status => 400}
      end
    end
    
  end
    
end