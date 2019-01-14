class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat

  sync :all
  sync_scope :by_chat, ->(chat) { where(chat_id: chat.id) }

  def self.search_messages(params, current_user)
    Message.joins(:user).where("users.id = ?", current_user.id).where("messages.body LIKE ?", "%#{params[:query]}%")
  end

end
