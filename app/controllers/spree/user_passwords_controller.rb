class Spree::UserPasswordsController < Devise::PasswordsController
  helper 'spree/users', 'spree/base', 'spree/store'

  if defined?(Spree::Dash)
    helper 'spree/analytics'
  end

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::SSL

  ssl_required

  # Overridden due to bug in Devise.
  #   respond_with resource, :location => new_session_path(resource_name)
  # is generating bad url /session/new.user
  #
  # overridden to:
  #   respond_with resource, :location => spree.login_path
  #
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      respond_with resource, :location => spree.login_path
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  # Devise::PasswordsController allows for blank passwords.
  # Silly Devise::PasswordsController!
  # Fixes spree/spree#2190.
  def update
    if params[:spree_user][:password].blank?
      set_flash_message(:error, :cannot_be_blank)
      render :edit
    else
      self.resource = resource_class.reset_password_by_token(resource_params)

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_resetting_password_path_for(resource)
      else
        respond_with resource
      end
    end
  end
  
  protected
  
    def after_resetting_password_path_for(resource)
      'http://kaufmann-mercantile.com'
    end
end
