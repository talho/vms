class Vms::QualificationsController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required, :change_include_root
  before_filter :initialize_scenario, :except => [:list]
  after_filter :change_include_root_back
  
  def index
    @si = @scenario.site_instances.all(:include => { :site => [], :role_scenario_sites => :role })
    tags = []
    
    @si.each do |si|
      tags << si.qualification_list.map { |q| {:name => q, :site_id => si.site_id, :site => si.site.name} }
      tags << si.role_scenario_sites.map { |r| r.qualification_list.map { |q| {:name => q, :role => r.role.name, :site_id => si.site_id, :site => si.site.name} } }
    end
    
    tags.flatten!
    
    respond_to do |format|
      format.json {render :json => tags.as_json}
    end
  end
  
  def show
    
  end
  
  def create
    
  end
  
  def update
    
  end
  
  def list
    tags = User.tag_counts_on(:qualifications)
    
    respond_to do |format|
      format.json { render :json => tags.as_json }
    end
  end
end