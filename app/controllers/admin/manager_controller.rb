module Admin
  class ManagerController < AdminController
    def index
      @list = page model
    end

    def new
      add_breadcrumb "Add #{breadcrumbs.last.name}"
      @current = model.new
    end

    def create
      @current = model.new(model_params)
      if current.save
        redirect_to action: :index
      else
        render :new
      end
    end

    def edit
      add_breadcrumb "Edit #{breadcrumbs.last.name}"
      current
    end

    def update
      if current.update(model_params)
        redirect_to action: :index
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
      self.class._parent_models.(it)
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

    helper_method :current
    def current
      @current ||= model.find(params[:id])
    end

    # render
    def render(*args)
      if template_exists?("#{controller_path}/#{params[:action]}")
        super(*args)
      else
        super(*(args << {
          template: "/admin/manager/#{params[:action]}",
        }.merge(args.extract_options!)))
      end
    end
  end
end
