class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show update destroy ]

  # GET /messages
  def index
    @messages = Message.all

    render json: @messages, only: [:number, :msg_body, :created_at]
  end

  # SEARCH /messages/search?q=
  def search
    vars = request.query_parameters
    word = vars["q"]
    if vars[:q].nil?
      render json: {error: "Must provide search keyword"}, status: :bad_request
    else
      app_token = params[:application_token]
      chat_number = params[:chat_number]
      @msgs = Message.search(word, app_token, chat_number)
      render json: @msgs, only: [:number, :msg_body, :created_at]
    end
  end
  
  # GET /messages/1
  def show
    render json: @message, only: [:number, :msg_body, :created_at]
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

    render json: x = {number: msgs_count, msg_body: msg}, status: :created
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      render json: @message, only: [:number, :msg_body]
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
      @message = Message.find_by(number: params[:number])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:msg_body)
    end
end
