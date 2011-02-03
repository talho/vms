ActionController::Routing::Routes.draw do |map|
  map.resources :vms_scenarios, :controller => 'vms/scenarios', :as => 'vms/scenarios' do |scenarios|
    scenarios.resources :vms_sites, :controller => 'vms/sites', :as => 'sites', :collection => [:existing]
    scenarios.resources :vms_inventories, :controller => 'vms/inventories', :as => 'inventories'
  end
end