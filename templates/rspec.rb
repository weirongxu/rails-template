run("bundle exec guard init spec")
generate("rspec:install")
insert_into_file(
  "spec/rails_helper.rb",
  after: /require ['"]rspec\/rails["']\n#.*\n/,
) do
<<-EOF
Devise.stretches = 1
Rails.logger.level = 4
EOF
end

insert_before_end(
  'spec/rails_helper.rb',
) do
  <<-EOF
  config.render_views

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include APISupport, type: :request, file_path: %r{spec/api}
  config.include ControllerSupport, type: :controller, file_path: %r{spec/controller}
  config.include FactoryBot::Syntax::Methods
  EOF
end
