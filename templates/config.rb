directory "config"

inject_into_class(
  "config/application.rb",
  "Application",
) do
  <<-EOF
    config.time_zone = 'Asia/Shanghai'
  EOF
end
