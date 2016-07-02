class SessionsController < ApplicationController
  layout 'no_auth'

  helper_method :form
  attr_reader :form

  def new
    redirect_to collections_path if current_user
    @form = AuthenticateForm.new
  end

  def create
    @form  = AuthenticateForm.new(params[:authenticate_form])
    action = AuthenticateUser.new(form)

    if action.run
      session_record = Session.new(
        user:         action.user,
        session_time: Time.now,
        session_data: "",
        ip_address:   request.remote_ip,
        session_id:   SecureRandom.hex(16)
      )
      if session_record.save
        session[:wt_session_id]  = session_record.session_id
        cookies['WT_SESSION'] = session_record.session_id
        redirect_to collections_path
        return
      end
    end

    flash_error_on_render "You could not be logged in with that username/password combination."
    render :new
  end

  def destroy
    if (session_record = Session.find_by(session_id: session[:wt_session_id]))
      session_record.delete
      flash_success_on_redirect "You have been logged out."
      redirect_to login_path
    else
      flash_success_on_redirect "You could not be logged out."
      redirect_to request.referrer
    end
  end

  private

  def check_successful_authentication
    if current_user
      url = params[:rurl]
      url = colections_path if url.blank?
      redirect_to URI.decode(url.strip)
    end
  end

  def check_needs_password_reset
    if current_user && current_user.needs_password_reset
      flash_error_on_redirect('You were assigned a temporary password. Please change it now.')
      redirect_to account_password_path
    end
  end
end
