ActionController::Routing::Routes.draw do |map|
  map.resources :vms_scenarios, :controller => 'vms/scenarios', :as => 'vms/scenarios' do |scenarios|
    scenarios.resources :vms_sites, :controller => 'vms/sites', :as => 'sites', :collection => [:existing] do |sites|
      sites.roles_show 'roles.:format', :controller => 'vms/roles', :action => 'show', :conditions => { :method => :get }
      sites.roles_update 'roles.:format', :controller => 'vms/roles', :action => 'update', :conditions => { :method => [:put, :post] }
    end
    scenarios.resources :vms_inventories, :controller => 'vms/inventories', :as => 'inventories', :collection => [:templates]
    scenarios.roles 'roles', :controller => 'vms/roles', :action => 'index'
  end
  
  map.inventory_sources 'vms/inventory_sources.:format', :controller => 'vms/inventories', :action => 'sources'
  map.inventory_items 'vms/inventory_items.:format', :controller => 'vms/inventories', :action => 'items'
  map.inventory_item_categories 'vms/inventory_item_categories.:format', :controller => 'vms/inventories', :action => 'categories'
end