class AuthenticateUser

  attr_accessor :user
  attr_reader :form

  def initialize(form)
    @form = form
  end

  def allowed?
    return false unless form.valid?
    true
  end

  def run
    return false unless allowed?

    # Authenticate the user by user_name and password.
    form.user_name = form.user_name.downcase.strip
    form.password  = form.password.strip
    @user = User.authenticate(form.user_name, form.password)

    form.errors[:user_name] << "unknown or invalid password." unless user

    user.present?
  end
end
