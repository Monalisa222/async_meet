class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login

  before_action :require_organization

  helper_method :current_user

  helper_method :current_organization

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    redirect_to login_path, alert: "You must be logged in to access this section."
  end

  def current_organization
    return unless current_user && session[:organization_id]
    
    @current_organization ||= current_user.organizations.find_by(id: session[:organization_id])
  end

  def require_organization
    return if current_organization

    redirect_to organizations_path, alert: "You must select an organization to access this section."
  end

  def current_membership
    return unless current_user && current_organization

    @current_membership ||= current_organization.memberships.find_by(user_id: current_user.id)
  end
end
