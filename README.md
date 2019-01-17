# 果壳树洞-ucaschat 

果壳树洞-RailsChat是基于ruby on rails开发的在线实时的Web聊天软件，用来完成国科大软件工程课程ruby大作业；本软件实现如下功能：包括聊天机器人功能，聊天管理功能中的撤回、转发、删除，聊天功能界面中的等待好友申请，添加好友，发起聊天，查找用户，查找聊天记录等功能；
## 一、主要功能
#### 用户功能：
* 可以通过右上角图标来管理用户的个人信息，同时可以查看、修改自己的用户信息；

#### 聊天功能：
* 在左侧四大功能模块中，可以查看好友列表，点击好友可以查看好友信息、发起聊天、删除好友等；聊天房间功能显示当前所有的聊天房间；好友申请功能为别人想要添加自己为好友，点击之后选择同意或者不同意；等待信息为添加别人，等待别人同意，也可撤回好友申请；
            

#### 机器人功能：
* 在好友列表机器人中，通过添加好友robot，可以和机器人在线聊天；user1用户已经添加robot用户，在好友列表中可以看到；
           

#### 查找功能：
* 可以通过左下角添加朋友按钮添加朋友，然后点击搜索（不输入内容）可以查看所有的好友，同时可以通过用户名查找，进行添加；可以通过右上角搜索按钮查找历史信息，点击搜索（不输入内容）会显示所有的聊天记录，同时可以通过关键字查找； 


#### 聊天管理功能：
*  在选择一个好友点击发起聊天，然后点击已经发送的一条信息，可以进行撤回消息，转发消息，删除消息三个功能；在右侧房间管理功能中，有添加当前聊天会话的用户人数，并可以修改房间名，转移房间的所有权权限；

## 二、使用截图
![Image text](/app/assets/images/1.png)
![Image text](/app/assets/images/2.png)
![Image text](/app/assets/images/3.png)
![Image text](/app/assets/images/robot.png)
![Image text](/app/assets/images/user-message.png)
![Image text](/app/assets/images/6.png)
![Image text](/app/assets/images/4.png)
![Image text](/app/assets/images/5.png)
![Image text](/app/assets/images/7.png)
![Image text](/app/assets/images/8.png)

## 三、系统测试用户
请点击[这里-ucaschat](http://39.106.148.76:3000/)访问ucaschat系统，系统测试测试用户登陆账号格式为：

```
username: user1@test.com
password: password
```

* 在系统中已经注册好100个用户，分别是user1@test.com,user2@test.com,user3@test.com...等，密码全都是password；robot机器人是默认用户，每个普通用户可以搜索robot来自动添加好友，在添加好友中可以通过查询用户名比如user2，或者直接不输入，点击搜索会显示所有的用户；可以通过两个浏览器分别登陆不同的用户来测试消息的即使推送，注意这两个用户需要互为好友。
## 四、UserStory
![Image text](/app/assets/images/userstory.jpg)
## 五、系统启动
1. Fork项目然后启动服务器

  ```
  git clone https://github.com/zhanghengjingyu/UCAS_Chat_ruby_homework.git
  cd UCAS_Chat_ruby_homework
  bundle install
  rails server -b 0.0.0.0 -d
  ```

2. 然后再打开另外一个终端，运行以下命令启动另外一个server来监听聊天室的用户并实时推送最新的消息：

  ```
  bundle exec rackup sync.ru -E production --host 0.0.0.0 -D
  ```




