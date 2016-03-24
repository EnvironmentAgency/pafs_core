# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::AccountRequestsController < PafsCore::ApplicationController
  def show
    @account_request = PafsCore::AccountRequest.find_by!(slug: params[:id])
  end

  def new
    @account_request = PafsCore::AccountRequest.new
  end

  def create
    @account_request = PafsCore::AccountRequest.new(account_params)
    if @account_request.save
      #TODO: send a confirmation?
      redirect_to @account_request
    else
      render "new"
    end
  end

  private
  def account_params
    params.require(:account_request).
      permit(:first_name, :last_name, :email, :organisation, :job_title,
             :telephone_number, :terms_accepted, :provisioned)
  end
end
