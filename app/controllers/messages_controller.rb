class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show update destroy ]

  # GET /messages
  def index
    @messages = Message.all

    render json: @messages
  end

  # SEARCH /messages/search?q=
  def search
    vars = request.query_parameters
    word = vars["q"]
    app_token = params[:application_token]
    chat_number = params[:chat_number]
    @msgs = Message.search(word, app_token, chat_number)
    render json: @msgs, only: [:number,:msg_body, :created_at]
  end
  
  # GET /messages/1
  def show
    render json: @message
  end
  
  def create
    redis = Rails.cache.redis.checkout
    app_token = params[:application_token]
    chat_number = params[:chat_number]
    msg = message_params[:msg_body]
    # TODO: Atom
    msgs_count = redis.incr("chat_#{app_token}_#{chat_number}_msgs_count")
    PresistAndIndexMsgJob.perform_async(app_token, chat_number, msgs_count, msg)

    Rails.cache.redis.checkin

    render json: x = {application_token: app_token, chat_number: chat_number, number: msgs_count, msg_body: msg}, status: :created
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:msg_body)
    end
end
