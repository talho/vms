ActionController::Routing::Routes.draw do |map|
  map.resources :vms_scenarios, :controller => 'vms/scenarios', :as => 'vms/scenarios', :member => {:execute => :put, :pause => :put, :stop => :put, :alert => :put, :copy => [:post, :put]} do |scenarios|
    scenarios.resources :vms_sites, :controller => 'vms/sites', :as => 'sites', :collection => [:existing] do |sites|
      sites.roles_show 'roles.:format', :controller => 'vms/roles', :action => 'show', :conditions => { :method => :get }
      sites.roles_update 'roles.:format', :controller => 'vms/roles', :action => 'update', :conditions => { :method => [:put, :post] }
      sites.staff_show 'staff.:format', :controller => 'vms/staff', :action => 'show', :conditions => { :method => :get }
      sites.staff_update 'staff.:format', :controller => 'vms/staff', :action => 'update', :conditions => { :method => [:put, :post] }
      sites.resources :vms_teams, :controller => 'vms/teams', :as => 'teams', :except => [:index]
      sites.qualifications_create 'qualifications.:format', :controller => 'vms/qualifications', :action => 'create', :conditions => { :method => :post }
      sites.qualifications_update 'qualifications.:format', :controller => 'vms/qualifications', :action => 'update', :conditions => { :method => :put }
      sites.qualifications_destroy 'qualifications.:format', :controller => 'vms/qualifications', :action => 'destroy', :conditions => { :method => :delete }
    end
    scenarios.resources :vms_inventories, :controller => 'vms/inventories', :as => 'inventories', :collection => [:templates]
    scenarios.roles 'roles.:format', :controller => 'vms/roles', :action => 'index'
    scenarios.staff 'staff.:format', :controller => 'vms/staff', :action => 'index'
    scenarios.teams 'teams.:format', :controller => 'vms/teams', :action => 'index'
    scenarios.quals 'qualifications.:format', :controller => 'vms/qualifications', :action => 'index'
  end

  map.vms_session_new 'vms/session/new', :controller => "vms/sessions", :action => 'new', :conditions => { :method => :get }
  map.vms_session_create 'vms/session/create', :controller => "vms/sessions", :action => 'create', :conditions => { :method => :post }
  map.vms_session_destroy 'vms/session/destroy', :controller => "vms/sessions", :action => 'destroy'#, :conditions => { :method => :get }
  map.kiosk_index 'vms/kiosk', :controller => "vms/kiosks", :action => 'index'
  map.kiosk_show 'vms/kiosk/:id.:format', :controller => "vms/kiosks", :action => 'show'  
  map.site_checkin 'vms/site_checkin.:format', :controller => "vms/kiosks", :action => 'registered_checkin'
  map.site_walkup 'vms/site_walkup.:format', :controller => "vms/kiosks", :action => 'walkup_checkin'
  map.vms_active_sites 'vms/user_active_sites', :controller => "vms/sites", :action => 'user_active_sites', :conditions => { :method => :get }

  map.inventory_sources 'vms/inventory_sources.:format', :controller => 'vms/inventories', :action => 'sources'
  map.inventory_items 'vms/inventory_items.:format', :controller => 'vms/inventories', :action => 'items'
  map.inventory_item_categories 'vms/inventory_item_categories.:format', :controller => 'vms/inventories', :action => 'categories'
  map.qualification_list 'vms/qualifications.:format', :controller => 'vms/qualifications', :action => 'list'
  map.resources :vms_user_qualifications, :as => 'vms/user_qualifications', :controller => 'vms/user_qualifications', :only => [:index, :create, :destroy]
  map.resources :vms_alerts, :as => 'vms/alerts', :controller => 'vms/alerts', :only => [:index], :member => {:acknowledge => :post}
end