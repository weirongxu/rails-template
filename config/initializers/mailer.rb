Rails.application.config.tap do |config|
  config.action_mailer.delivery_method = :smtp

  # config.action_mailer.smtp_settings = {
  #   address: 'smtp.exmail.qq.com',
  #   port: 465,
  #   domain: 'qq.com',
  #   user_name: '',
  #   password: '',
  #   authentication: 'plain',
  #   enable_starttls_auto: true,
  #   ssl: true,
  # }

  # config.action_mailer.smtp_settings = {
  #   address: 'smtp.gmail.com',
  #   # port: 587,
  #   port: 465,
  #   user_name: '',
  #   password: '',
  #   authentication: :plain,
  #   enable_starttls_auto: true,
  #   ssl: true,
  # }
end
