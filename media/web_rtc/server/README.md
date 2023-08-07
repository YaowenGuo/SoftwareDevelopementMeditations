# 启动流程

安装 Node.js 依赖包

```
npm install
```

启动 node.js 服务器。

```
node index.js
```


连接流程

```
Caller                      Signaling-Server                       Callee
  |                            |                                    |
  ├------- ➀ Connect --------->|                                    |
➁ Get Media                    |                                    |
  |------- got user media ---->|<----------- ➂ Connect -------------┤
  |                            |                                ➃ Get Media
  |<------ got user media -----┼<--------- got user media ----------|
➄ Create Offer                 |                                    |
  ├------ Send Offer --------->|----------------------------------->|
  |                            |                           ➅ Create Answer
  |<---------------------------|------------- Send Ansder ----------┤
  |                            |                                    |
➆ ICE <=== multi times ========|========== Send ICE ===========> ➇ ICE
  |

```

`*` 测试demo，每个房间仅允许两个用户。

`*`其中 ICE 在 Create Offer 之后即可产生，不一定等到接收到对方的 Answer。因此有可能在接收到 Answer 之前就产生了。默认使用 trickle ICE, ICE 分产生多次，多次发送。

`*` 以为服务器没有将客户端接收的 Offer/Answer 缓存起来。所以需要客户端在两端都连接之后再发送 Offer/Anwer，即接收到 “got user media” 消息的时候。
