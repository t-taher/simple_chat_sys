class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show update destroy ]

  # GET /chats
  def index
    vars = request.query_parameters
    limit = vars[:limit] || 5
    offset = vars[:offset] || 0

    @chats = Chat.limit(limit).offset(offset).order(number: :desc).joins(:application).where(application: { token: params[:application_token] }).includes(:application)

    render json: @chats, only: [:number, :msg_count, :created_at], include: [:application => {:only => :token}]
  end

  # GET /chats/1
  def show
    render json: @chat, only: [:number, :msg_count, :created_at], include: [:application => {:only => :token}]
  end

  # POST /chats
  def create
    redis = Rails.cache.redis.checkout
    app_token = params[:application_token]
    # TODO: Atom
    chats_count = redis.incr("applicaiton_#{app_token}_chats_count")
    PresistChatInDbJob.perform_async(app_token, chats_count)

    Rails.cache.redis.checkin

    render json: x = {application_token: app_token, number: chats_count}, status: :created
  end
  
  # PATCH/PUT /chats/1
  def update
    if @chat.update(chat_params)
      render json: @chat, only: [:number, :msg_count, :created_at], include: [:application => {:only => :token}]
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # DELETE /chats/1
  def destroy
    @chat.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.joins(:application).where(application: { token: params[:application_token] }).includes(:application).find_by(number: params[:number])
    end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat)
    end
end
