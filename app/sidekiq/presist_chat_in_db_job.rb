class PresistChatInDbJob
  include Sidekiq::Job

  def perform(app_token, chat_number)
    app = Application.find_by(token: app_token)
    Chat.transaction do
      chat = Chat.create(application_id: app.id, number: chat_number)
      app.increment! :chats_count
    end
    Rails.logger.debug "Success presisted chat with app_token: #{app_token}, number: #{chat_number}"
  end
end
