class Vms::StaffController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required, :change_include_root
  before_filter :initialize_scenario
  after_filter :change_include_root_back
  
  def index
    @instances = @scenario.site_instances.find(:all, :include => {:staff => [:user, :site]})
    @staff = @instances.map(&:staff).flatten
    respond_to do |format|
      format.json {render :json => @staff.as_json }
    end
  end
  
  def show
    @site_instance = @scenario.site_instances.for_site(params[:vms_site_id])
    respond_to do |format|
      format.json {render :json => @site_instance.staff.find(:all, :include => [:user , :site]).as_json }
    end
  end
  
  def update
    @site_instance = @scenario.site_instances.first( {:conditions => {:site_id => params[:vms_site_id]}, :include => [:role_scenario_sites] })
    
    staff = JSON.parse(params[:staff])
    
    # pull out new, updated, and deleted staff from params
    new_staff = staff.select{|s| s['status'] == 'new'}
    updated_staff = staff.select{|s| s['status'] == 'updated'}
    deleted_staff = staff.select{|s| s['status'] == 'deleted'}
    
    current_staff = @site_instance.staff
    
    #delete existing staff
    deleted_staff.each do |s|
      db_staff = current_staff[current_staff.index{ |ts| ts.id === s['id']}]
      db_staff.mark_for_destruction
    end
    
    #create new staff
    new_staff.each do |s|
      s.delete('status')
      @site_instance.role_scenario_sites.build(s)
    end
    
    #update existing staff
    updated_staff.each do |s|
      s.delete('status')
      db_staff = rss[rss.index{ |ts| ts.id === s['id']}]
      db_staff.attributes = s
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