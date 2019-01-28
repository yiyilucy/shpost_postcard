ShpostPostcard::Application.routes.draw do

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
  root 'welcome#index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  resources :user_logs, only: [:index, :show, :destroy]
  resources :catalogs

   

  resources :users do
    member do
      get 'to_reset_pwd'
      patch 'reset_pwd'
    end
    resources :permissions
  end

  resources :user_permissions

  resources :permissions do
    collection do
      post 'do_permission'
    end
  end


  resources :front_users

  resources :bills do
    collection do
      get 'to_import'
      post 'import' => 'bills#import'
      post 'export'
      get 'price_import'
      post 'price_import' => 'bills#price_import'
      post 'price_export'
    end
  end

  resources :coins do
    collection do
      get 'to_import'
      post 'import' => 'coins#import'
      post 'export'
      get 'price_import'
      post 'price_import' => 'coins#price_import'
      post 'price_export'
    end
  end

  resources :stamps do
    collection do
      get 'to_import'
      post 'import' => 'stamps#import'
      post 'export'
      get 'price_import'
      post 'price_import' => 'stamps#price_import'
      post 'price_export'
    end
  end

  resources :commodities do 
    resources :prices, :controller => 'commodity_price'
    resources :import_files, :controller => 'commodity_import_file'
  end
  
  resources :prices do
    collection do
      get 'to_import'
      post 'import' => 'prices#import'
      post 'export'
    end
  end

  resources :dic_contents

  resources :dic_titles do 
    resources :dic_contents
  end

  resources :import_files do
    collection do
      get 'to_import'
      post 'import' => 'import_files#import'
    end
    member do 
      get 'download'
      post 'download' => 'import_files#download'
    end
  end

  resources :commodity_autocom do
    collection do
      get 'autocomplete_commodity_name'
    end
  end
  
end
