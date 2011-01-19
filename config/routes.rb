ActionController::Routing::Routes.draw do |map|
  map.resources :vms_scenarios, :controller => 'vms/scenarios', :as => 'vms/scenarios' 
end