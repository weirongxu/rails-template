require 'active_support/concern'

module QiniuAble
  extend ActiveSupport::Concern

  included do
    def self.qiniu_styles(url, query: nil, iv: nil, w: nil, h: nil)
      if url&.include? CarrierWave::Uploader::Base.qiniu_bucket_domain
        if query
          uri = URI(url)
          uri.query = query + '&' + uri.query
          uri.to_s
        elsif iv
          query = iv.except(:mode).reduce('') do |ret, (key, value)|
            ret += key.to_s + '/' + value.to_s + '/'
          end
          qiniu_styles(url, query: "/imageView2/#{iv[:mode]}/#{query}")
        elsif w || h
          if not h
            qiniu_styles(url, iv: {mode: 0, w: w})
          elsif not w
            qiniu_styles(url, iv: {mode: 0, h: h})
          else
            qiniu_styles(url, iv: {mode: 0, w: w, h: h})
          end
        else
          url
        end
      else
        url
      end
    end

    def self.mount_image(column, target="#{column}&.url")
      class_eval <<-RUBY, __FILE__, __LINE__+1
      def #{column}_url(**args)
        self.class.qiniu_styles(#{target}, **args)
      end
    RUBY
    end
  end
end
