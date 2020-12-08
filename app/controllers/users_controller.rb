class UsersController < ApplicationController
  before_action :auth_hash, only: [:create]

  def index
    @users = User.all
    if @user.nil?
      flash[:result_text] = "You must log in to do that"
      return redirect_to root_path
    end
  end

  def show
    @exist_user = User.find_by(id: params[:id])
    return render_404 unless @exist_user

    if @user.nil?
      flash[:result_text] = "You must log in to do that"
      return redirect_to root_path
    end
  end

  def create
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    
    if user
      flash[:result_text] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:result_text] = "Logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:result_text] = "Successfully logged out!"

    redirect_to root_path
    return
  end

  protected
  def auth_hash
    request.env["omniauth.auth"]
  end
end
