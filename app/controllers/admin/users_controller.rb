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
        flash.now[:success] = 'User was successfully created.'
        render :show
      else
        flash.now[:error] = ['User could not be successfully created.']
        render :new
      end
    end

    def update
      if user.update_user(user_params)
        flash.now[:success] = 'User was successfully updated.'
        render :show
      else
        flash.now[:error] = ['User could not be successfully updated.']
        render :edit
      end
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
