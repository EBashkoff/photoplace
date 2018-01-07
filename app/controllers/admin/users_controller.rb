module Admin
  class UsersController < ApplicationController

    before_action :require_is_admin
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    helper_method :user, :users
    attr_reader :user, :users

    def index
      @users = User.order(:real_name).page(params[:page]).per(13)
    end

    def show
      set_user
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      @user = User.new

      if user.update_user(user_params)
        flash[:success] = 'User was successfully updated.'
        render :show
      else
        flash[:error] = ['User could not be successfully updated.']
        render :new
      end
    end

    def update
      if user.update_user(user_params)
        flash[:success] = 'User was successfully updated.'
      else
        flash[:error] = ['User could not be successfully updated.']
      end
      render :edit
    end

    def destroy
      user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params
        .require(:user)
        .permit(:user_name, :real_name, :email, :password, :password_confirmation)
        .select { |_, v| v.present? }
    end

  end
end
