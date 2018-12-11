class HomeController < ApplicationController
  before_action :check_permission, only: [:index]

  def index
  end

  def not_allowed
  end

  private

  def check_permission
    if current_user
      if current_user.admin?
        redirect_to '/admin'
      else
        sign_out
        redirect_to '/not_allowed'
      end
    else
      redirect_to '/user/sign_in'
    end
  end
end
