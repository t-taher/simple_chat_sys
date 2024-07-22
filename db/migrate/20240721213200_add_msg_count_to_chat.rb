class AddMsgCountToChat < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :msg_count, :integer, :default => 0
  end
end
