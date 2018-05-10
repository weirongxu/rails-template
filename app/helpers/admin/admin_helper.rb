module Admin::AdminHelper
  def ldate(dt, options = {})
    dt ? l(dt, options) : nil
  end

  def link_btn(*args, &block)
    options = args.extract_options!
    if not options.has_key?(:class)
      options[:class] = "btn btn-#{options.fetch(:size, 'sm')} btn-#{options.fetch(:type, 'primary')}"
    end
    link_to(*(args << options), &block)
  end

  def link_operations(it)
    [
      link_edit(it),
      link_destroy(it),
    ].join(' ').html_safe
  end

  def link_edit(it)
    link_btn('Edit', [:edit, :admin, *parent_models(it), it], type: 'primary')
  end

  def link_destroy(it)
    link_btn('Destroy', [:admin, *parent_models(it), it], type: 'danger', data: {method: :delete, confirm: 'Are you sure to delete?'})
  end

  def simple_form_for(*args, **kwg, &block)
    if args.size == 0
      args = [[:admin, *parent_models, current]]
    end
    super(*args, **kwg, &block)
  end
end
