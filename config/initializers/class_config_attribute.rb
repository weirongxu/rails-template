class Class
  # Add class config attribute
  #
  # ==== Examples
  #
  #  class Application
  #    class_config_attribute :config, {default_value: 123}
  #  end
  #
  #  class App < Application
  #    config({a: 'a'})
  #  end
  #
  #  Application._config
  #  # {default_value: 123}
  #
  #  App._config
  #  # {default_value: 123, a: 'a'}
  #
  def class_config_attribute(attr, default={})
    pri_attr_get = "_#{attr}".to_sym
    pri_attr_put = "_#{attr}=".to_sym
    class_attribute pri_attr_get
    send(pri_attr_put, default)

    define_singleton_method(attr.to_sym) do |config|
      source = send(pri_attr_get)
      if source.is_a?(Hash) && config.is_a?(Hash)
        send(pri_attr_put, source.merge(config))
      else
        send(pri_attr_put, config)
      end
    end

    class_eval do
      define_method(attr.to_sym) do
        self.class.send(pri_attr_get)
      end
    end

  end
end
