ActionController::Routing::Routes.draw do |map|
  map.resources :vms_scenarios, :controller => 'vms/scenarios', :as => 'vms/scenarios' do |scenarios|
    scenarios.resources :vms_sites, :controller => 'vms/sites', :as => 'sites', :collection => [:existing]
    scenarios.resources :vms_inventories, :controller => 'vms/inventories', :as => 'inventories', :collection => [:templates]
  end
  
  map.inventory_sources 'vms/inventory_sources', :controller => 'vms/inventories', :action => 'sources'
end