directory "app"

route <<-EOF
namespace :tests do
  get :controller_must_reload
  get :test_email
  get :email_job
  get :delay_job
  get :exception_email
  get :exception_email_job
  get '/actioncable/:name', action: :actioncable
end
EOF

inject_into_class(
  "app/controllers/application_controller.rb",
  "ApplicationController",
) do
  <<-EOF
  protect_from_forgery with: :exception
  include HaltCtrl, PowerCtrl
  EOF
end

insert_before_end(
  "app/mailers/application_mailer.rb",
) do
  <<-EOF

  def send_email(to:, subject:, content: '')
    @content = content
    mail(to: to, subject: subject)
  end
  EOF
end

insert_before_end(
  "app/models/application_record.rb",
) do
  <<-EOF
  extend Enumerize
  include QiniuAble, PowerAble
  EOF
end
