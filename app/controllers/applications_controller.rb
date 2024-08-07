class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[ show update destroy ]

  # GET /applications
  def index
    vars = request.query_parameters
    limit = vars[:limit] || 5
    offset = vars[:offset] || 0

    @applications = Application.limit(limit).offset(offset).order(created_at: :desc)

    render json: @applications, only: [:token, :name, :chats_count, :created_at]
  end

  # GET /applications/1
  def show
    render json: @application, only: [:token, :name, :chats_count, :created_at]
  end

  # POST /applications
  def create
    @application = Application.new(application_params)

    if @application.save
      render json: @application, status: :created, location: @application, only: [:token, :chats_count, :name, :created_at]
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/1
  def update
    if @application.update(application_params)
      render json: @application, only: [:token, :name, :chats_count, :created_at]
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/1
  def destroy
    @application.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by(:token => params[:token])
    end

    # Only allow a list of trusted parameters through.
    def application_params
      params.require(:application).permit(:name)
    end
end