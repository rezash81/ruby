class PagesController < ApplicationController
  def index; end
  def about; end
  def gallery; end
  def products; end
  def contact; end

  def app
    authenticate_user!
    @app = true
  end

  def test
    cookies["Client_Version"] = "c4b0e47a86f4f779"
    render text: 'c4b0e47a86f4f779'
  end

  def me
    authenticate_user!
    @app = true
  end

  def update_me
    authenticate_user!
    @app = true
    if params[:current_password] and params[:password] and params[:password_confirm]
      if current_user.valid_password? params[:current_password]
        if params[:password] == params[:password_confirm]
          if params[:password].length > 5
            current_user.update password: params[:password]
            flash.now[:notice] = "پسورد با موفقیت عوض شد."
          else
            flash.now[:error] = "پسورد باید حداقل ۶ حرف باشد"
          end
        else
          flash.now[:error] = "پسوردها شبیه هم نیستند"
        end
      else
        flash.now[:error] = "پسورد فعلی درست نیست"
      end
    else
      flash.now[:error] = "اطلاعات ورودی صحیح نیست"
    end
    redirect_to me_path
  end

  def get_update
    # if cookies["Client_Version"] and cookies["Client_Version"] == UConf[:app_version]
    #   send_data File.open(Rails.root+'update.zip'), disposition: :attachment, filename: 'update.zip'
    # else
    #   render text: ''
    # end

    if cookies["Client_Version"]
      @device = ClientInfo.where(guid: cookies["Client_Version"]).first
      if @device and @device.zipupdate
        begin
          return send_file @device.zipupdate.path, disposition: :attachment, filename: 'update.zip'
        rescue
        end
        # send_data File.open(Rails.root+'update.zip'), disposition: :attachment, filename: 'update.zip'
      end
    end
    render text: '', status: 404
  end

end
