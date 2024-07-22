class Message < ApplicationRecord
  belongs_to :chat
  validates :msg_body, :presence => true
end
