Shop::Engine.routes.draw do

    resources :district_transports
    get "district_transports/get_price/:id",to: "district_transports#get_price"

    resources :one_orders
    resources :one_products

    resources :customer_types
    resources :customers
    get "customers/get_districts/:id",to: "customers#get_districts"

    resources :tags
    resources :product_skus
    resources :product_properties
    resources :property_values
    resources :properties

    post "orders/add_to_cart"
    post "orders/create_order"
    post "orders/alipay_notify"
    get "orders/empty_cart"
    get "orders/remove_from_cart/:id",to: "orders#remove_from_cart"
    get "orders/change_product_quantity/:id",to: "orders#change_product_quantity"
    get "orders/delivery/:id",to: "orders#delivery",as: 'order_delivery'
    
    get "pictures/set_cover_picture/:id" , to: "pictures#set_cover_picture", as: 'pictures_set_cover_picture'
    get "products/add_relation/:id" , to: "products#add_relation", as: 'products_add_relation'
    delete "products/del_relation/:id" , to: "products#del_relation", as: 'products_del_relation'
    resources :order_items
    resources :orders
    resources :pictures
    resources :products
    resources :categories
end
