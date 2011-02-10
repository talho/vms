class Vms::InventoriesController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  before_filter :initialize_scenario, :except => [:sources]
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
      format.json {render :json => @inventories.map { |inv| inv.as_json(:include => {:site => {:only => [:id] }, :source => {:only => [:name]} }) } }
    end    
  end
  
  def show
    begin
      inventory = Vms::Inventory.find(params[:id], :include => {:item_instances => {:item => :item_category}, :source => {} } )
      @inventory_json = inventory.as_json(:include => {:source => {:only => [:name] }}).merge(:items => inventory.item_instances.as_json)
    rescue
      @inventory_json = {}
    end
    
    respond_to do |format|
      format.json {render :json => @inventory_json }
    end
  end
  
  def new
    
  end
  
  def create
    #create inventory
    @inv = Vms::Inventory.new params[:inventory]
    
    if params[:source] && !params[:source].blank?
      @inv.source = Vms::Inventory::Source.find_or_create_by_name(params[:source])
    end
    
    #create/lookup items, add to default item instance
    ic = @inv.item_collections.build(:status => Vms::Inventory::ItemCollection::STATUS[:available])
    params[:items].each do |item|
      item = item[1] #readdress the item to be the 2nd array item
      #create item instance and set its quantity
      ii = ic.item_instances.build(:quantity => item[:quantity])
      ii.item = Vms::Inventory::Item.find_by_name(item[:name]) || (Vms::Inventory::Item.new :name => item[:name], :consumable => item[:consumable] == 'true')
      ii.item.item_category = Vms::Inventory::ItemCategory.find_or_create_by_name(item[:category]) if item[:category] && !item[:category].blank?
    end unless params[:items].nil?
    
    #if it's a template, duplicate for assignment
    if params[:inventory][:template] == 'true' && @inv.save!
      @inv = @inv.clone
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
      inventory = @scenario.inventories.find(params[:id], :include => {:item_instances => {:item => :item_category}, :source => {} } )
      @inventory_json = inventory.as_json(:include => {:source => {:only => [:name] }}).merge(:items => inventory.item_instances.as_json)
    rescue
      @inventory_json = {}
    end
    
    respond_to do |format|
      format.json {render :json => @inventory_json }
    end
  end
  
  def update
    @inv = @scenario.inventories.find(params[:id])
    @inv.attributes = params[:inventory]
    #update source
    if params[:source] && !params[:source].blank?
      @inv.source = Vms::Inventory::Source.find_or_create_by_name(params[:source])
    end
    
    #update items
    updated_items = []
    ic = @inv.item_collections.find_or_build_by_status(Vms::Inventory::ItemCollection::STATUS[:available])
    unless params[:items].nil?
      params[:items].each do |item|
        item = item[1] #readdress the item to be the 2nd array item
        #find the item
        it = Vms::Inventory::Item.find_or_create_by_name(item[:name])
        it.consumable = item[:consumable] == 'true'
        if item[:category] && !item[:category].blank?
          it.item_category = Vms::Inventory::ItemCategory.find_or_create_by_name(item[:category])
          it.save!
        end 
        
        ii = ic.item_instances.find_or_build_by_item(it)
        ii.quantity = item[:quantity]
        ii.save!
        updated_items << ii
      end 
      #clear items that were not touched
      for_deletion = ic.item_instances - updated_items
      for_deletion.map(&:destroy)
    end
    
    unless params[:site].nil? || params[:site].blank?
      @inv.scenario_site = @scenario.site_instances.for_site(params[:site_id])  
    end
    
    respond_to do |format|
      if @inv.save 
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
  
  def templates
    templates = Vms::Inventory.templates.by_name(params[:name])
    respond_to do |format|
      format.json {render :json => templates.as_json }
    end
  end
  
  def sources
  	respond_to do |format|
  		format.json { render :json => Vms::Inventory::Source.find(:all, :conditions => "name LIKE '%#{params[:name]}%'") }
  	end
  end
  
  private
  def initialize_scenario
    begin
      @scenario = Vms::Scenario.find(params[:vms_scenario_id])
    rescue Exception => e
      respond_to do |format|
        format.json {render :json => {:exception => e.message, :backtrace => e.backtrace, :error => "Could not find the requested scenario.", :success => false}, :status => 404}
      end
      false
    end
  end
end