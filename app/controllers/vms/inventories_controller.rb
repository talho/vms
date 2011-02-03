class Vms::InventoriesController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  before_filter :initialize_scenario
  after_filter :change_include_root_back
  
  def index
    @inventories = []
    if params[:site_id].nil?
      @inventories = @scenario.inventories
    else
      @scenario_site = @scenario.site_instances.for_site(params[:site_id])
      @inventories = @scenario_site.inventories unless @scenario_site.nil?
    end
    
    respond_to do |format|
      format.json {render :json => @inventories }
    end    
  end
  
  def show
    begin
      @inventory = @scenario.inventories.find(params[:id])
    rescue
      @inventory = {}
    end
    
    respond_to do |format|
      format.json {render :json => @inventory }
    end
  end
  
  def new
    
  end
  
  def create
    unless params[:inventory][:id].nil?
      #create from existing
      @inv = Vms::Inventory.find(params[:inventory][:id]).dup
    else
      #create inventory
      @inv = Vms::Inventory.create params[:inventory]
    end
    #if it's a template, duplicate for assignment
    if params[:inventory][:template] == 'true'
      @inv = @inv.dup
    end
    
    #assign to site
    @inv.scenario_site = @scenario.site_instances.for_site(params[:site_id])
    
    #save duplication
    respond_to do |format|
      if @inv.save!
        format.json {render :json => {:inventory => @inv, :success => true}}
      else
        format.json {render :json => {:errors => @inv.errors, :success => false}, :status => 406 }
      end
    end
  end
  
  def edit
    begin
      @inventory = @scenario.inventories.find(params[:id])
    rescue
      @inventory = {}
    end
    
    respond_to do |format|
      format.json {render :json => @inventory }
    end
  end
  
  def update
    @inv = @scenario.inventories.find(params[:inventory][:id])
    
    respond_to do |format|
      if @inv.update_attributes params[:inventory]
        format.json {render :json => {:inventory => @inv, :success => true}}
      else
        format.json {render :json => {:errors => @inv.errors, :success => false}, :status => 406 }
      end
    end
  end
  
  def destroy    
    @inv = @scenario.inventories.find(params[:inventory][:id])
    
    respond_to do |format|
      if @inv.destroy #should remove all of the  
        format.json {render :json => {:inventory => @inv, :success => true}}
      else
        format.json {render :json => {:errors => @inv.errors, :success => false}, :status => 406 }
      end
    end
  end
  
  private
  def initialize_scenario
    @scenario = Vms::Scenario.find(params[:vms_scenario_id])
  end
end