class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action {@app = true}
  before_action {@tab = 'user'}

  def index
    @users = User.where("user_type < ?", current_user.user_type)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.user_type >= current_user.user_type
      return render action: 'new', notice: "خطای درسترسی"
    end

    if @user.save
      redirect_to @user
    else
      render action: 'new'
    end
  end

  def update
    _params = user_params
    # _params.delete :user_type
    if @user.update(_params)
      redirect_to @user
    else
      render action: 'edit'
    end
  end

  def destroy
    if @user.super_admin?
      redirect_to user_path(@user), notice: 'یوزر ادمین کل غیر قابل حذف میباشد'
    else
      @user.destroy
      redirect_to users_url
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      _ret = params.require(:user).permit(:username, :name, :email, :password, :password_confirmation, :user_type)
      _ret.each do |k,v|
        _ret.delete k if v.length == 0
      end
    end
end
