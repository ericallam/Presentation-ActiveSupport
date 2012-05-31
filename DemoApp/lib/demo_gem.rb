module DemoGem
  class Middleware
    def initialize(app); @app = app; end
    def call(env)
      puts env.inspect
      @app.call(env)
    end
  end

  if defined?(ActiveSupport)
    ActiveSupport.on_load(:after_initialize) do
      self.config.middleware.insert_before ActionDispatch::Static, DemoGem::Middleware
    end
  end
end

