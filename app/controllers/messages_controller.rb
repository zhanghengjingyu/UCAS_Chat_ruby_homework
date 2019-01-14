require 'json'
require 'net/http'
require 'monitor'

class MessagesController < ApplicationController
  include SessionsHelper
  before_action :set_message, only: [:update, :destroy]

  def create
    @message = current_user.messages.build(message_params)
    chat=Chat.find_by_id(params[:chat_room])
    if @message.body==''
      redirect_to chat_path(chat), flash: {:warning => '发送消息不能为空'} and return
    end
    redirect_to chats_path, flash: {:warning => '此聊天不存在'} and return if chat.nil?
    @message.chat=chat
    if @message.save
      sync_new @message, scope: chat
    else
      redirect_to chat_path(chat), flash: {:warning => '消息发送失败'} and return
    end
    if "robot".eql? chat.users[-1].name and
      send_to_robot chat.users[-1], message_params['body'], chat, -2
      redirect_to chat_path(chat), flash: {:warning => '回复消息失败'} and return
    elsif "robot".eql? chat.users[-2].name and
         send_to_robot chat.users[-2], message_params['body'], chat, -1
      redirect_to chat_path(chat), flash: {:warning => '回复消息失败'} and return
    end
    redirect_to chat_path(chat)
  end

  def destroy
    @message = Message.find(params[:id])
    chat=Chat.find_by_id(params[:chat_room])
    @message.destroy
    sync_destroy @message
    redirect_to chat_path(chat)
  end

  def destroyall
    chat=Chat.find_by_id(params[:chat_room])
    chat.messages.delete_all
    redirect_to chat_path(chat), flash: {info: '聊天记录已清空'}
  end

  def index_json
    @messages=Message.search_messages(params, current_user)
    render json: @messages.as_json
  end

  private
  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:body)
  end

  @@apikey_users = {
    '51575c6f13db42a8af42fe4f2215a905' => [],
    '6da94bb802f540af95091594a31d76f9' => [],
    'd7021112324046fda711ae92c7660c65' => [],
    'b2ad6c9c9a694d41ba71ad5fdf39ee31' => [],
    '0c481d6075fb4c08a634c1fdf023c59b' => [],
  }

  @@user_array = nil

  @@apikey_users_lock = Monitor.new

  def self.allcate_apikey(id)
    @@apikey_users.each do |key, array|
      return key if array.include? id
    end
    @@apikey_users_lock.synchronize do
      MessagesController.allcate_apikey_aux(id)
    end
  end

  def self.allcate_apikey_aux(id)
    first_key = nil
    first_array = nil
    next_one = false
    @@apikey_users.each do |key, array|
      if next_one
        @@user_array = array
        array << id
        return key
      end
      if first_key.nil?
        first_key = key
        first_array = array
      end
      if @@user_array.equal? array
        next_one = true
      end
    end
    @@user_array = first_array
    first_array << id
    first_key
  end

  def send_to_robot(robot, message_body, chat, who)
    hash = {
      reqType: 0,
      perception: { inputText: { text: message_body } },
      userInfo: {
        apiKey: MessagesController.allcate_apikey(chat.users[who].id),
        userId: chat.users[who].id
      }
    }
    data = MessagesController.capture_stdout { print(JSON.generate hash) }
    uri = URI 'http://openapi.tuling123.com/openapi/api/v2'
    http = Net::HTTP.new uri.host
    response = http.post uri.path, data, { 'content-type' => 'text/plain', 'charset' => 'utf-8' }
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts '!!!!!!!'
      puts response.body
      reply_hash = JSON.parse response.body
      if reply_hash["results"].nil?
        return false
      end
      reply_hash["results"].each do |hash|
        hash["values"].each do |key, value|
          message = MessagesController.capture_stdout { print value }
          return true if build_reply(robot, chat, message)
        end
      end
      return false
    else
      return true
    end
  end

  def build_reply(robot, chat, message)
    reply_params = { 'body' => message }
    reply = robot.messages.build reply_params
    reply.chat = chat
    if reply.save
      sync_new reply, scope: chat
    else
      return true
    end
    return false
  end

  @@capture_lock = Monitor.new

  def self.capture_stdout(&block)
    @@capture_lock.synchronize do
      MessagesController.capture_stdout_aux block
    end
  end

  def self.capture_stdout_aux(proc)
    origin = $stdout
    $stdout = StringIO.new
    proc.call
    $stdout.string
  ensure
    $stdout = origin
  end
end

# def update
#   respond_to do |format|
#     if @message.update(message_params)
#       format.html { redirect_to @message, notice: 'Message was successfully updated.' }
#       format.json { render :show, status: :ok, location: @message }
#     else
#       format.html { render :edit }
#       format.json { render json: @message.errors, status: :unprocessable_entity }
#     end
#   end
# end
