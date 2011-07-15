class Vms::UserQualificationsController < ApplicationController
  
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    respond_to do |format|
      format.json {render :json => current_user.qualifications.all.as_json }
    end
  end
  
  def create
    respond_to do |format|
      name = params[:name]
      if name.blank?
        format.json {render :json => {:success => false, :message => "Qualification name cannot be blank."}, :status => 400}
      else      
        current_user.qualification_list << name.downcase
        current_user.save
        format.json {render :json => current_user.qualifications.find_by_name(name.downcase).as_json.merge(:success => true) }
      end
    end
  end
  
  def destroy
    current_user.qualifications.delete(current_user.qualifications.find(params[:id]))
    current_user.save
    respond_to do |format|
      format.json {render :json => {:success => true}}
    end
  end
end