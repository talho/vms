class Vms::VolunteersController < ApplicationController  
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  def index
    vols = current_user.jurisdictions.vms_admin.map(&:vms_volunteers).flatten.uniq.sort {|a, b| a[:last_name] <=> b[:last_name]}
    
    paging = !params[:start].nil? || params[:paged] == 'true'
    if paging
      per_page = params[:limit] || 50
      page = ( (params[:start]||0).to_i/(per_page).to_i ) + 1
      vols = vols.paginate(:page => page, :per_page => per_page)
    end
    
    respond_to do |format|
      format.json {render :json => {:vols => vols.map{|x| x.as_json(:only => [:display_name, :id, :email])}, :total => paging ? vols.total_entries : vols.count } }
    end
  end
end