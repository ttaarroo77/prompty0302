class ApplicationController < ActionController::Base
  # ブラウザのバージョンによる制限を適用しない
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    prompts_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
