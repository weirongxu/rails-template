module Admin
  class ManagerController < AdminController
    def index
      @list = page model_query
    end

    def new
      add_breadcrumb "Add #{breadcrumbs.last.name}"
      @current = model_query.new
    end

    def create
      @current = model_query.new(model_params)
      if current.save
        redirect_to url_for([:admin, *parent_models, model])
      else
        render :new
      end
    end

    def show
      edit
      render :edit
    end

    def edit
      add_breadcrumb "Edit #{breadcrumbs.last.name}"
      current
    end

    def update
      if current.update(model_params)
        redirect_to url_for([:admin, *parent_models, model])
      else
        render :edit
      end
    end

    def destroy
      current.destroy
      redirect_back
    end

    protected
    # model
    def self.model(model)
      @_model = model
    end

    def self._model()
      @_model
    end

    helper_method :model
    def model
      self.class._model
    end

    helper_method :model_query
    def model_query
      self.class._model
    end

    def self.parent_models(&block)
      @_parent_models = block
    end

    def self._parent_models
      @_parent_models || ->(it) {
        []
      }
    end

    helper_method :parent_models
    def parent_models(it=current)
      self.instance_exec(it, &self.class._parent_models)
    end

    # params
    def self.model_params(*args)
      @_model_params = args.flatten
    end

    def self._model_params
      @_model_params
    end

    def model_params(&block)
      @model_params ||= params.require(model.name.underscore.to_sym).permit(*self.class._model_params)
    end

    def self.table_fields(*table_fields)
      to_fn = -> (field) {
        if field.is_a? Symbol
          -> (it) {
            is_value = it.is_a?(ApplicationRecord)
            field = field.to_s
            if field.include?('.')
              fields = field.split(/&?\./)
              if is_value
                binding.eval("it.#{fields.join('&.')}")
              else
                *reflections, attr = fields
                binding.eval("it.#{reflections.map{|f| "reflections['#{f}'].klass"}.join('.')}")
                  .human_attribute_name(attr)
              end
            else
              if is_value
                it.send(field)
              else
                it.human_attribute_name(field)
              end
            end
          }
        elsif field.is_a? String
          -> (it) {
            field
          }
        else
          field
        end
      }
      @_table_fields = table_fields.map do |field|
        if field.is_a?(Symbol)
          [to_fn.call(field), to_fn.call(field)]
        elsif field.is_a?(Array)
          [to_fn.call(field[0]), to_fn.call(field[1])]
        else
          nil
        end
      end.compact
    end

    def self._table_fields
      @_table_fields
    end

    helper_method :table_fields
    def table_fields
      self.class._table_fields
    end

    helper_method :current
    def current
      @current ||= model_query.find(params[:id])
    end

    # switch
    def self.new_able(val)
      @_new_able = val
    end

    def self._new_able
      @_new_able != false
    end

    helper_method :new_able?
    def new_able?
      self.class._new_able
    end

    def self.operations_able(val)
      @_operations_able = val
    end

    def self._operations_able
      @_operations_able != false
    end

    helper_method :operations_able?
    def operations_able?
      self.class._operations_able
    end

    # render
    def render(*args, &block)
      options = _normalize_render(*args, &block)
      action = options.fetch(:action, params[:action])
      if template_exists?("#{controller_path}/#{action}")
        super(*args, &block)
      else
        super(*(args << {
          template: "/admin/manager/#{action}",
        }.merge(args.extract_options!)), &block)
      end
    end
  end
end
