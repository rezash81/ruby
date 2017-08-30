class ClientInfosController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_client_info, only: [:show, :edit, :update, :destroy]
  before_action {@app = true}
  before_action {@tab = 'client_info'}

  def index
    @client_infos = ClientInfo.all
  end

  def show
  end

  def new
    @client_info = ClientInfo.new
  end

  def edit
  end

  def create
    @client_info = ClientInfo.new(client_info_params)

    if @client_info.save
      redirect_to @client_info, notice: 'Client info was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @client_info.update(client_info_params)
      redirect_to @client_info, notice: 'Client info was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @client_info.destroy
    redirect_to client_infos_url
  end

  private
    def set_client_info
      @client_info = ClientInfo.find(params[:id])
    end

    def client_info_params
      params.require(:client_info).permit(:name, :position, :guid, :model_name, :serial_number, :product_date_time, :hw_config, :client_status, :description, :update)
    end
end
