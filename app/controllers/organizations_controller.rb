class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:switch]

  def index
    @organizations = current_user.organizations
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.active = true
    if @organization.save
      Membership.create(user: current_user, organization: @organization, role: :owner, active: true)

      session[:organization_id] = @organization.id
      redirect_to organizations_path, notice: "Organization created successfully."
    else
      flash.now[:alert] = @organization.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def switch
    if current_user.organizations.exists?(@organization.id)
      session[:organization_id] = @organization.id
      redirect_to organizations_path, notice: "Switched to organization #{@organization.name}."
    else
      redirect_to organizations_path, alert: "You do not have access to this organization."
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :industry, :website)
  end
end
