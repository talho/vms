class Vms::VolunteersController < ApplicationController  
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    vols = current_user.jurisdictions.vms_admin.map(&:vms_volunteers).flatten.uniq.sort {|a, b| a[:display_name] <=> b[:display_name]}.paginate(:page => 1, :per_page => 50)
    
    respond_to do |format|
      format.json {render :json => {:vols => vols.map{|x| x.as_json(:only => [:display_name, :id, :email])}, :total => vols.total_entries}}
    end
  end
end