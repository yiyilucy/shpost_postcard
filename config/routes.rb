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

  # devise_for :front_users, controllers: { sessions: "front_users/sessions" }
  devise_for :front_users
  as :front_user do
    get 'front_users/sign_in' => 'front_users/sessions#new', :as => :new_front_user_session
    post 'front_users/sign_in' => 'devise/sessions#create', :as => :front_user_session
    delete 'front_users/sign_out' => 'devise/sessions#destroy', :as => :destroy_front_user_session
  end

  resources :user_logs, only: [:index, :show, :destroy]
  resources :catalogs
  resources :postcard_views do
    collection do
      get 'index'
      get 'list_tab'
      get 'list_normal'
      get 'product'
      get 'appraisal'
      get 'news'
      get 'value'
      # get 'sorting_edit'
      get 'sorting'
      # get 'sorting_collection'
      # get 'list_normal_collection'
      get 'follow'
      get 'product_follow'
      # get 'product_sorting'
    end
  end

  resources :sortings do
    collection do
      get 'product_sorting'
      get 'sorting_edit'
      get 'sorting_collection'
      get 'list_normal_collection'
    end
  end

  resources :follows do
    collection do
      get 'product_follow'
    end
  end

  resources :list_tabs do
    collection do
      get 'product'
      get 'list_normal', to: 'list_tabs#list_normal'
    end
    
  end
   

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


  resources :front_users do
    member do
      get 'collection_index'
    end
  end

  resources :bills do
    collection do
      get 'to_import'
      post 'import' => 'bills#import'
      post 'export'
      get 'price_import'
      post 'price_import' => 'bills#price_import'
      post 'price_export'
      get 'to_image_import'
      post 'image_import' => 'bills#image_import'
      get 'to_batch_image_import'
      post 'batch_image_import' => 'bills#batch_image_import'
    end
    member do
      get 'image_index'
      get 'image_download'
      post 'image_download' => 'bills#image_download'
      delete 'image_destroy' => 'bills#image_destroy'
      post 'image_set_master'
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
      get 'to_image_import'
      post 'image_import' => 'coins#image_import'
      get 'to_batch_image_import'
      post 'batch_image_import' => 'coins#batch_image_import'
    end
    member do
      get 'image_index'
      get 'image_download'
      post 'image_download' => 'coins#image_download'
      delete 'image_destroy' => 'coins#image_destroy'
      post 'image_set_master'
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
      get 'to_image_import'
      post 'image_import' => 'stamps#image_import'
      get 'to_batch_image_import'
      post 'batch_image_import' => 'stamps#batch_image_import'
    end
    member do
      get 'image_index'
      get 'image_download'
      post 'image_download' => 'stamps#image_download'
      delete 'image_destroy' => 'stamps#image_destroy'
      post 'image_set_master'
    end
  end

  resources :commodities do 
    resources :prices, :controller => 'commodity_price'
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
      get 'image_index'
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

  resources :banners do 
    collection do
      post 'do_create'
      post 'do_update'
    end
  end

  resources :collections do
    collection do
      post 'export'
      get 'collection_index'
      get 'search'
      get 'filter'
    end
    member do 
      get 'destroy'
      get 'update'
    end
  end


  
end
