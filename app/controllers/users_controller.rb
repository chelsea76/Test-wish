class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :finish_signup]

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    return unless request.patch? && params[:user]
    return @show_errors = true unless @user.update(user_params)
    sign_in @user, bypass: true
    redirect_to root_path, notice: 'Your profile was successfully updated.'
  end

  # GET /users/1/edit
  def edit
  end

  def show
    @user = User.find(params[:id])
    @posts = current_user.posts.order("id DESC")
  rescue
    redirect_to root_path
  end

  def profile
    @user = User.find(params[:id])
  rescue
    redirect_to root_path
  end

  def profile_update
    current_user.update_attributes(user_params)
    redirect_to root_path, notice: 'User profile has been updated successfully.'
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to account_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: account_path }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def activities
    @activities = User.user_activities(current_user.id)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit :email, :headline, :name
  end
end
