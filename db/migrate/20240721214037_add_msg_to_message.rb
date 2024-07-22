class AddMsgToMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :msg_body, :string
  end
end
