require "rails/railtie"

require "webpacker/helper"
require "webpacker/dev_server_proxy"

class Webpacker::Engine < ::Rails::Engine
  initializer "webpacker.proxy" do |app|
    if Rails.env.development?
      app.middleware.insert_before 0,
        Rails::VERSION::MAJOR >= 5 ?
          Webpacker::DevServerProxy : "Webpacker::DevServerProxy"
    end
  end

  initializer "webpacker.helper" do |app|
    ActiveSupport.on_load :action_controller do
      ActionController::Base.helper Webpacker::Helper
    end

    ActiveSupport.on_load :action_view do
      include Webpacker::Helper
    end
  end

  initializer "webpacker.logger" do
    config.after_initialize do |app|
      Webpacker.logger = ::Rails.logger
    end
  end

  initializer "webpacker.bootstrap" do
    Webpacker.bootstrap
    Spring.after_fork { Webpacker.bootstrap } if defined?(Spring)
  end
end
