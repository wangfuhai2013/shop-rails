module Shop
  class Engine < ::Rails::Engine
    isolate_namespace Shop
    
    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*.rb").each do |c|        
        require_dependency(c)
      end
    end
   
    initializer "shop.assets.precompile" do |app|
     app.config.assets.precompile += %w(shop/products.css shop/products.js)
   end

  end
end