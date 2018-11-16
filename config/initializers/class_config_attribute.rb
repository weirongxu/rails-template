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
  #  Application.new.config
  #  # {default_value: 123}
  #
  #  App._config
  #  # {default_value: 123, a: 'a'}
  #
  #  App.new.config
  #  # {default_value: 123, a: 'a'}
  #
  def class_config_attribute(attr, default={})
    attr = attr.to_sym
    inner_attr_get = "_#{attr}".to_sym
    inner_attr_put = "_#{attr}=".to_sym
    class_attribute inner_attr_get
    send(inner_attr_put, default)

    define_singleton_method(attr) do |config|
      source = send(inner_attr_get)
      if source.is_a?(Hash) && config.is_a?(Hash)
        send(inner_attr_put, source.deep_merge(config))
      else
        send(inner_attr_put, config)
      end
    end

    class_eval do
      define_method(attr) do
        run_proc = -> (value, parent: nil) {
          if value.is_a? Proc
            value.call(self, parent)
          elsif value.is_a? Hash
            value.transform_values do |it|
              run_proc.call(it, parent: value)
            end
          elsif value.is_a? Array
            value.map do |it|
              run_proc.call(it, parent: value)
            end
          else
            value
          end
        }

        val = instance_variable_get(:"@#{attr}")
        return val if val
        instance_variable_set(:"@#{attr}", run_proc.call(self.class.send(inner_attr_get)))
      end
    end

  end
end
