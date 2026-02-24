class OrganizationsController < ApplicationController
  skip_before_action :require_organization, only: [:index, :new, :create, :switch]
  before_action :require_owner, only: [:add_member]

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
    org_id = params[:organization_id]

    @organizations = current_user.organizations
    if current_user.organizations.exists?(org_id)
      session[:organization_id] = org_id
      respond_to do |format|
        format.html { redirect_to organizations_path, notice: "Switched to organization #{Organization.find(org_id).name}." }
        format.turbo_stream
      end
    else
      redirect_to organizations_path, alert: "You do not have access to this organization."
    end
  end

  def add_member
    @organization = current_user.organizations.find(params[:id])
    user = User.find_by(email: params[:email])

    if user.nil?
      redirect_to organizations_path, alert: "User with email #{params[:email]} not found."
      return
    end

    if @organization.memberships.exists?(user_id: user.id)
      redirect_to organizations_path, alert: "User #{user.email} is already a member of this organization."
      return
    end

    Membership.create(user: user, organization: @organization, role: :member, active: true)
    redirect_to organizations_path, notice: "User #{user.email} added to organization #{@organization.name}."
  end


  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :industry, :website)
  end
end
