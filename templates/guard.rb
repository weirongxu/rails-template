run("bundle exec guard init")
prepend_to_file("Guardfile", "require('dotenv/load')\n")
gsub_file("Guardfile", /guard ['"]rails['"] do/, 'guard "rails", port: ENV["PORT"] do')
dev_env = <<-EOF
config.middleware.use Rack::LiveReload, {
  host: ENV['HOST'],
}
EOF
environment(dev_env, env: 'development')
