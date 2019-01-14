class FriendshipsController < ApplicationController
  include SessionsHelper
  before_action :logged_in

  def create
    friendid = params[:friend_id]
    if !friendid.nil?
      @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
      user = User.find_by_id(params[:friend_id])
      add_robot user
    else
      user=User.find_by_id(params[:id])
      apply=user.friendships.find_by(friend_id: current_user[:id])
      if !apply.nil?
        @friendship = current_user.friendships.build(:friend_id => params[:id])
        add_robot user
      end
    end
    if !@friendship.nil? and @friendship.save
      flash[:info] = "发送请求成功"
      redirect_to chats_path
    else
      flash[:error] = "无法添加好友"
      redirect_to chats_path
    end
  end

  def destroy
    @friendship = current_user.friendships.find_by(friend_id: params[:id])
    if !@friendship.nil?
      @friendship.destroy
    end

    user=User.find_by_id(params[:id])
    current_user.chats.each do |chat|
      if (chat.users-[user, current_user]).blank?
        chat.destroy
      end
    end

    @friendship = user.friendships.find_by(friend_id: current_user[:id])
    if !@friendship.nil?
      @friendship.destroy
    end

    flash[:success] = "删除好友成功"
    redirect_to chats_path
  end

  private
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def add_robot(robot)
    if "robot".eql? robot.name
      robotfriend = robot.friendships.build(:friend_id => current_user[:id])
      if !robotfriend.nil?
        robotfriend.save
      end
    end
  end

end
