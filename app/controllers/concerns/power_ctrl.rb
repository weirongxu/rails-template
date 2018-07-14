module PowerCtrl
  extend ActiveSupport::Concern

  included do
    def page(record, per_page=10)
      record.page(params[:page]).per(per_page)
    end

    # redirect_back default using root_path as fallback_location
    def redirect_back(fallback_location: self.redirect_back_default, **args)
      super(fallback_location: fallback_location, **args)
    end

    helper_method :current_url
    def current_url full: false, only_path: false
      path = only_path ? request.path : request.fullpath
      if full
        "#{request.protocol}#{request.host_with_port}#{path}"
      else
        path
      end
    end

    def self.default_url_options
      {
        host: ENV['HOST'],
        port: ENV['PORT'],
      }
    end

    def self.redirect_back_default(default)
      @redirect_back_default = default
    end

    def self.get_redirect_back_default
      @redirect_back_default
    end

    def redirect_back_default
      @redirect_back_default || root_path
    end

    def paramsify(data)
      if data.is_a?(Array)
        data.map do |it|
          ActionController::Parameters.new(it)
        end
      else
        ActionController::Parameters.new(data)
      end
    end

    def request_json
      @request_json ||= JSON.parse(request.body.read)
    end

    def params_json
      paramsify(request_json)
    end

    def params_get
      paramsify(request.GET)
    end

    def params_post
      paramsify(request.POST)
    end

    helper_method :render_if
    def render_if(options)
      if options.is_a? String
        options = {partial: options}
      end
      if template_exists?(options[:partial], [], true)
        render_to_string(options).html_safe
      else
        if block_given?
          yield
          ''
        else
          ''
        end
      end
    end

    rescue_from(ActiveRecord::ActiveRecordError) do |err|
      raise err if not err.respond_to? :record

      case
      when self.is_a?(ActionController::Base)
        respond_to do |format|
          format.html {
            redirect_back alert: err
          }
          format.json {
            render json: {
              status: 'error',
              message: err
            }, status: 400
          }
        end
      when self.is_a?(ActionController::API)
        render json: {
          status: 'error',
          message: err
        }, status: 400
      end
    end
  end
end
