class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show update destroy ]

  # GET /chats
  def index
    @chats = Chat.joins(:application).where(application: { token: params[:application_token] }).includes(:application)

    render json: @chats, only: [:number, :created_at], include: [:application => {:only => :token}]
  end

  # GET /chats/1
  def show
    render json: @chat, only: [:number,:created_at], include: [:application => {:only => :token}]
  end

  # POST /chats
  def create
    @chat = Chat.new(chat_params)

    if @chat.save
      render json: @chat, status: :created, location: @chat, only: [:number,:created_at], include: [:application => {:only => :token}]
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /chats/1
  def update
    if @chat.update(chat_params)
      render json: @chat, only: [:number,:created_at], include: [:application => {:only => :token}]
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
      params.require(:chat).permit(:number, :application_token)
    end
end
