class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy, :post, :unpost]
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action  :verify_authorized

  def index
    posted_messages = Message.posted
    postable_messages = Message.postable
    messages = posted_messages.or(postable_messages)
    @messages = messages.paginate(page: params[:page], per_page: 5).order(created_at: :desc)
    authorize @messages
  end

  def inactive_messages
    messages = Message.unposted
    @messages = messages.paginate(page: params[:page], per_page: 5).order(created_at: :desc)
    authorize @messages
  end

  def new
    @message = Message.new
    authorize @message
  end

  def create
    @message = Message.new(message_params)
    authorize @message
    if @message.save
      flash[:notice] = "Message created."
      redirect_to messages_path
    else
      render 'new'
    end
  end

  def show
    authorize @message
  end

  def edit
    authorize @message
  end

  def update
    authorize @message
    if @message.update_attributes(message_params)
      flash[:notice] = "Message updated."
      redirect_to messages_path
    else
      render 'edit'
    end
  end

  def destroy
    authorize @message
    @message.destroy
    flash[:success] = "Message deleted."
    redirect_to messages_path
  end

  def post
    authorize @message
    if !@message.posted? && @message.posted_at.nil?
      @message.update(posted: true, posted_at: Time.zone.now)

      devices = Device.all
      client = Exponent::Push::Client.new
      messages = []
      messages = devices.map do |device|
        {
          to: device.token,
          sound: "default",
          title: device.selected_lang == 'en' ? @message.title : @message.titulo,
          body:  device.selected_lang == 'en' ? @message.body : @message.cuerpo,
          data: {
                  id: @message.id,
                  title: { en: @message.title, es: @message.titulo },
                  body: { en: @message.body,  es: @message.cuerpo },
                  message_type: @message.message_type,
                  updated_at: @message.updated_at,
                  posted_at: @message.posted_at
                }
        }
      end

      begin
        client.send_messages messages
      rescue Exponent::Push::UnknownError => e
        Rails.logger.info e.message
      end

      flash[:notice] = "Message posted."
      redirect_to request.referrer || messages_path
    end
  end

  def unpost
    authorize @message
    if @message.posted? && !@message.posted_at.nil?
      @message.update_attributes(posted: false)
      flash[:notice] = "Message unposted."
      redirect_to request.referrer || messages_path
    end
  end


  private

    def message_params
      params.require(:message).permit(:title, :body, :posted, :message_type, :titulo, :cuerpo)
    end

    def set_message
      @message = Message.find(params[:id])
    end
end
