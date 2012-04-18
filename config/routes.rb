Openphin::Application.routes.draw do
  namespace :vms do 
    resources :scenarios do
      member do 
        put :execute 
        put :pause
        put :stop
        put :alert
        put :copy
        post :copy
      end
      
      resources :sites do
        post :existing, :on => :collection
        get :existing, :on => :collection
        get 'roles(.:format)', :to => 'roles#show', :as => :roles_show
        put 'roles(.:format)', :to => 'roles#update', :as => :roles_update
        post 'roles(.:format)', :to => 'roles#update', :as => :roles_update
        get 'staff(.:format)', :to => 'staff#show', :as => :staff_show
        put 'staff(.:format)', :to => 'staff#update', :as => :staff_update
        post 'staff(.:format)', :to => 'staff#update', :as => :staff_update
        resources :teams, :except => [:index]
        post 'qualifications(.:format)', :to => 'qualifications#create', :as => :qualifications_create
        put 'qualifications(.:format)', :to => 'qualifications#update', :as => :qualifications_update
        delete 'qualifications(.:format)', :to => 'qualifications#destroy', :as => :qualifications_destroy
      end
      resources :inventories do
        get :templates, :on => :collection
      end
      get 'roles(.:format)', :to => 'roles#index', :as => :roles
      get 'staff(.:format)', :to => 'staff#index', :as => :staff 
      get 'teams(.:format)', :to => 'teams#index', :as => :teams 
      get 'qualifications(.:format)', :to => 'qualifications#index', :as => :quals 
    end
  
    resources :users, :only=> [:new, :create]
    
    # no app linking for now....   :collection => { :link_app => :put, :link_app_page => :get } 
    match 'session/new', :to => 'sessions#new', :via => :get, :as => :vms_session_new
    match 'session/create', :to => 'sessions#create', :via => :post, :as => :vms_session_create 
    match 'session/destroy', :to => 'sessions#destroy', :as => :vms_session_destroy 
    match 'kiosk', :to => 'kiosks#index', :as => :kiosk_index 
    match 'kiosk/:id(.:format)', :to => 'kiosks#show', :as => :kiosk_show 
    match 'site_checkin(.:format)', :to => 'kiosks#registered_checkin', :as => :site_checkin 
    match 'site_walkup(.:format)', :to => 'kiosks#walkup_checkin', :as => :site_walkup 
    match 'user_active_sites', :to => 'sites#user_active_sites', :via => :get, :as => :vms_active_sites 
  
    match 'inventory_sources(.:format)', :to => 'inventories#sources', :as => :inventory_sources 
    match 'inventory_items(.:format)', :to => 'inventories#items', :as => :inventory_items 
    match 'inventory_item_categories(.:format)', :to => 'inventories#categories', :as => :inventory_item_categories 
    match 'qualifications(.:format)', :to => 'qualifications#list', :as => :qualification_list 
    resources :user_qualifications, :only => [:index, :create, :destroy]
    resources :alerts, :only => [:index, :create, :show] do
      post :acknowledge, :on => :member
      get :status_checks, :on => :collection
    end 
    resources :volunteers, :only => [:index]
  end
end