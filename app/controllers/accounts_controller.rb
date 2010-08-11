class AccountsController < ApplicationController
  before_filter :require_user_session
  before_filter :load_account
  
  def edit
  end

  def update
    if @current_account.update_attributes(params[:account])
      flash[:notice] = "Account has been updated."
      redirect_to home_path
    else
      render :edit
    end
  end

end
