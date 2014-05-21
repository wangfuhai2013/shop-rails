Shop::Engine.routes.draw do
  resources :product_skus

  resources :product_properties

  resources :property_values

  resources :properties

    get "pictures/set_cover_picture/:id" , to: "pictures#set_cover_picture", as: 'pictures_set_cover_picture'
    resources :order_items
    resources :orders
    resources :pictures
    resources :products
    resources :categories
end
