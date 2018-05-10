module Admin
  class AdminController < ApplicationController
    add_breadcrumb 'Home', :admin_root_path
    before_action :authenticate_adminer!
    redirect_back_default :admin_root_path

    layout 'admin'
  end
end
