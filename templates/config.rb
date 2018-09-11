directory "config"

inject_into_class(
  "config/application.rb",
  "Application",
) do
  <<-EOF
    config.time_zone = 'Asia/Shanghai'
    config.default_url_options = { host: ENV['HOST'] }
    config.action_mailer.default_url_options = { host: ENV['HOST'] }
  EOF
end
