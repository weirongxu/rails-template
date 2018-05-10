if @omniauth
  initializer "config/initializers/omniauth.rb", <<-EOF
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
end
EOF
  if @devise and @devise_model
    insert_into_file(
      'config/initializers/devise.rb',
      after: /#\s\=\=\> OmniAuth(\n\s+#.+)*\n/,
    ) do
      "  config.omniauth :developer unless Rails.env.production?\n"
    end

    create_file "app/controllers/#{@devise_model.pluralize}/omniauth_callbacks_controller.rb" do
      <<-EOF
class #{@devise_model.classify.pluralize}::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include HaltCtrl, PowerCtrl
  skip_before_action :verify_authenticity_token  

  def developer
    @user = User.new
    @user.email = 'developer@dev.com'
    # @user.name = 'developer'
    # @user.nickname = 'raidou'
    @user.save!(validate: false)
    sign_in_and_redirect(@user, event: :authentication)
    set_flash_message(:notice, :success, kind: "Developer") if is_navigational_format?
  end

  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview#facebook-example
  # def facebook
  #   @user = User.from_omniauth(request.env["omniauth.auth"])
  #
  #   if @user.persisted?
  #     sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
  #     set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
  #   else
  #     session["devise.facebook_data"] = request.env["omniauth.auth"]
  #     redirect_to new_user_registration_url
  #   end
  # end

  def failure
    redirect_to root_path
  end
end
      EOF
    end
    gsub_file(
      'config/routes.rb',
      'devise_for :users',
      'devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }',
    )

    insert_into_file(
      "app/models/#{@devise_model}.rb",
      after: /devise((\n|\s)*:(\w|_)+,?)+/
    ) do
      ', :omniauthable'
    end

    insert_before_end(
      "app/models/#{@devise_model}.rb",
    ) do
      <<-EOF

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end
      EOF
    end

    generate(:migration, 'add_provider_and_uid_to_users', 'provider:string', 'uid:string')
  end
end
