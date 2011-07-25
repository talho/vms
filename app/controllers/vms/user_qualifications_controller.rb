class Vms::UserQualificationsController < ApplicationController
  
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    user = current_user
    user = User.find(params[:user_id]) unless params[:user_id].nil?
    
    respond_to do |format|
      format.json {render :json => user.qualifications.all.as_json }
    end
  end
  
  def create
    user = current_user
    user = User.find(params[:user_id]) unless params[:user_id].nil?
    
    respond_to do |format|
      name = params[:name]
      if name.blank?
        format.json {render :json => {:success => false, :message => "Qualification name cannot be blank."}, :status => 400}
      else      
        user.qualification_list << name.downcase
        user.save
        format.json {render :json => user.qualifications.find_by_name(name.downcase).as_json.merge(:success => true) }
      end
    end
  end
  
  def destroy
    user = current_user
    user = User.find(params[:user_id]) unless params[:user_id].nil?
    
    user.qualifications.delete(user.qualifications.find(params[:id]))
    user.save
    respond_to do |format|
      format.json {render :json => {:success => true}}
    end
  end
end