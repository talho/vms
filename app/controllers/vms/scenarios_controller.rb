
class Vms::ScenariosController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    @scenarios = current_user.scenarios
    respond_to do |format|
      format.json {render :json => {:scenarios => @scenarios.as_json(:only => [:id, :name] ) } }
    end
  end  
  
  def show
    @scenario = current_user.scenarios.find(params[:id])
    respond_to do |format|
      unless @scenario.nil?
        format.json {render :json => @scenario.as_json}
      else
        format.json {render :json => {:msg => 'You do not have permission to open this scenario'}, :status => 404 }
      end
    end
  end
  
  def new
    respond_to do |format|
      format.json {render :json => {} }
    end
  end
  
  def create
    @scenario = Vms::Scenario.new(params[:scenario])
    if @scenario.save
      respond_to do |format|
        format.json {render :json => {:scenario => @scenario.as_json, :success => true} }
      end
    else
      respond_to do |format|
        format.json {render :json => {:msg => 'Error creating the scenario', :errors => @scenario.errors }, :status => 406 }
      end
    end
  end
  
  def edit    
    @scenario = current_user.scenarios.find(params[:id])
    respond_to do |format|
      unless @scenario.nil?
        format.json {render :json => @scenario.as_json}
      else
        format.json {render :json => {:msg => 'You do not have permission to edit this scenario'}, :status => 404 }
      end
    end
  end
  
  def update
    @scenario = current_user.scenarios.find(params[:id])
    if @scenario.update_attributes(params[:scenario])
      respond_to do |format|
        format.json {render :json => @scenario.as_json }
      end
    else
      respond_to do |format|
        format.json {render :json => {:msg => 'Error creating the scenario', :errors => @scenario.errors }, :status => 406 }
      end
    end
    
  end
end