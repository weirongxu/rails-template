module ApplicationHelper
  def cdn_url(url, min: true)
    if (min and Rails.env.production?)
      url.sub(/\.(js|css)$/, '.min\0')
    else
      url
    end.sub(/^https?:/, '')
  end

  def cdn_css(url, options={})
    stylesheet_link_tag(cdn_url(url, options))
  end

  def cdn_js(url, options={})
    javascript_include_tag(cdn_url(url, options))
  end
end
