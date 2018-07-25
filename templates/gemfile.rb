append_to_file 'Gemfile' do
  <<-EOF


group :development do
  # guard
  # guard init
  gem 'guard'
  gem 'guard-rails', require: false
  gem 'guard-livereload', require: false
  gem 'guard-rspec', require: false
  gem 'rack-livereload'

  # chrome rails_panel
  gem 'meta_request'

  # 模型自动注释comment
  gem 'annotate'

  # 增强rails console
  gem 'pry-rails'
  gem 'awesome_print'

  # 生成对象关系模型图
  gem 'railroady'

  # 漏洞检测
  gem 'brakeman', require: false

  # 自动部署
  gem 'capistrano'
  gem 'capistrano-rvm', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-sidekiq', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
end

# 系统错误邮箱提醒
gem 'exception_notification'

# 用户管理
#{@devise ? '' : '# '}gem 'devise'
#{@omniauth ? '' : '# '}gem 'omniauth'

# rails翻译
gem 'rails-i18n'
gem 'kaminari-i18n'
#{@devise ? '' : '# '}gem 'devise-i18n'

# 使用.env配置rails变量
gem 'dotenv-rails'

# 分页
gem 'kaminari'
gem 'api-pagination'

# 面包屑
gem 'breadcrumbs_on_rails'

# 权限功能
# gem 'pundit'

# 图片裁剪上传
gem 'carrierwave'
gem 'carrierwave-i18n'
# gem 'carrierwave-qiniu'
gem 'mini_magick'

# rails 后台定时与异步 任务
gem 'sidekiq'

# html模板
gem 'simple_form'
gem 'cocoon'

# es6
gem 'sprockets'
gem 'sprockets-es6'

# 拒绝 IE 6/7/8
gem 'browser_warrior'

# 富文本编辑器
# gem 'simditor'

# json serializer
gem 'active_model_serializers', '~> 0.10.0'

# 模型enum字段
gem 'enumerize'

# 模型伪删除
gem 'paranoia'

# 前端自动添加前缀
gem 'autoprefixer-rails'
  EOF
end
