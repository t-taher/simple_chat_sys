class PresistAndIndexMsgJob
  include Sidekiq::Job

  def perform(app_token, chat_number, msg_number, msg_body)
    app = Application.find_by(token: app_token)
    chat = Chat.find_by(application_id: app.id, number: chat_number)
    Message.transaction do
      msg = Message.create(chat_id: chat.id, number: msg_number, msg_body: msg_body)
      chat.increment! :msg_count
    end
    Rails.logger.debug "Success presisted msg with app_token: #{app_token}, chat_number: #{chat_number}, msg_number: #{msg_number}"
  end
end
