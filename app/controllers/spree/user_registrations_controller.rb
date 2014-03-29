class Spree::UserRegistrationsController < Devise::RegistrationsController
  helper 'spree/users', 'spree/base', 'spree/store'

  if defined?(Spree::Dash)
    helper 'spree/analytics'
  end

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::SSL

  ssl_required
  before_filter :check_permissions, :only => [:edit, :update]
  skip_before_filter :require_no_authentication

  # GET /resource/sign_up
  def new
    super
    @user = resource
  end

  # POST /resource/sign_up
  def create
    @user = build_resource(params[:spree_user])
    # if resource.save
    #   set_flash_message(:notice, :signed_up)
    #   sign_in(:spree_user, @user)
    #   session[:spree_user_signup] = true
    #   associate_user
    #   sign_in_and_redirect(:spree_user, @user)
    # else
    #   clean_up_passwords(resource)
    #   render :new
    # end
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected
    def check_permissions
      authorize!(:create, resource)
    end

    def after_inactive_sign_up_path_for(resource)
      cookies[:session_engaged] = {:value => 'confirm', :domain => '.kaufmann-mercantile.com'}
      'http://kaufmann-mercantile.com'
    end
end
