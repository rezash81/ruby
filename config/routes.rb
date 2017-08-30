Uasco::Application.routes.draw do

  get 'me' => 'pages#me', as: 'me'
  post 'me' => 'pages#update_me'
  # get 'gc' => 'pages#gc'
  get 'test' => 'pages#test'
  devise_for :users
  resources :users
  resources :clients do
    collection do
      get 'compare'
    end
    member do
      get 'attachments'
      post 'attachments' => 'clients#add_attachment'
      post 'attachments/:aid' => 'clients#set_default_attachment'
      delete 'attachments/:aid' => 'clients#delete_attachment'
      get 'sensors' => 'clients#get_sensors'
      post 'sensors' => 'clients#update_sensors'
      get 'check_new'
      get 'import_usb'
      post 'import_usb' => 'clients#import_usb_post'
      get 'export'
      get 'standard_export'
      get 'import'
      post 'import' => 'clients#import_data'
      get 'live'
      get 'archive_data'
      get 'export'
      get 'export_standard'
      get 'export_shown_data'
      get 'export_live_data'
    end
  end
  resources :sensors
  resources :client_infos

  post "post_data" => "packet#recieve"

  get 'RDLSystemServer/update.php' => 'pages#get_update'

  post "/RDLSystemServer/server.php" => "packet#recieve"
  get "/RDLSystemServer/server.php" => "packet#recieve"

  post "/RDLSecondServer/server.php" => "packet#second_recieve", as: :second_server_post
  get "/RDLSecondServer/server.php" => "packet#second_recieve"

  # get "compare_two_client" => "clients#compare_two_client"

  root 'pages#app'
  get 'about' => 'pages#about'
  get 'gallery' => 'pages#gallery'
  get 'products' => 'pages#products'
  get 'contact' => 'pages#contact'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
