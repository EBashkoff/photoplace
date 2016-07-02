class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout "auth"
  helper_method :current_user, :gallery_or_album

  def current_user
    @current_user ||= User.joins(:sessions).where("wt_session.session_id = ?", cookies['WT_SESSION']).first
  end

  def require_is_user
    if current_user
      session['wt_session_id'] ||= cookies['WT_SESSION']
      current_user
    else
      flash_error_on_redirect("You must log in to access that page.")
      redirect_to login_path(rurl: CGI::escape(request.fullpath))
    end
  end

  def require_is_admin
    if current_user && current_user.canadmin == "1"
      session['wt_session_id'] ||= cookies['WT_SESSION']
      current_user
    else
      flash_error_on_redirect("You cannot access this page unless you are an administrator.")
      redirect_to login_path(rurl: CGI::escape(request.fullpath))
    end
  end

  [:error, :success, :info, :notice, :warning].each do |key|
    define_method("flash_#{key}_on_render") do |message|
      flash.clear
      flash.now[key] ||= []
      flash.now[key] << message
    end

    define_method("flash_#{key}_on_redirect") do |message|
      flash.clear
      flash[key] ||= []
      flash[key] << message
    end
  end

  def gallery_or_album
    return "" unless request.referrer
    /\/album_(gallery|thumbs)\//.match(request.referrer) do |m|
      m[1].try(:titleize) || ""
    end.gsub("Thumbs", "Album")

  end

end
