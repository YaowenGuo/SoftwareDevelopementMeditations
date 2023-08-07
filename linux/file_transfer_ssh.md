# ssh
SSH是Secure SHell的缩写。由 IETF 的网络小组（Network Working Group）所制定；SSH 为建立在应用层基础
上的安全协议。SSH 是目前较可靠，专为远程登录会话和其他网络服务提供安全性的协议。利用 SSH 协议可以有效防
止远程管理过程中的信息泄露问题。SSH最初是UNIX系统上的一个程序，后来又迅速扩展到其他操作平台。SSH在正确使
用时可弥补网络中的漏洞。SSH客户端适用于多种平台。几乎所有UNIX平台—包括HP-UX、Linux、AIX、Solaris、Digital
UNIX、Irix，以及其他平台，都可运行SSH。
![SSH工作抽象图](https://baike.baidu.com/pic/ssh/10407/0/2cf5e0fe9925bc31c68ac31c57df8db1ca13705b?fr=lemma&ct=single#aid=0&pic=2cf5e0fe9925bc31c68ac31c57df8db1ca13705b)

# 功能
传统的网络服务程序，如：ftp、pop和telnet在本质上都是不安全的，因为它们在网络上用明文传送口令和数据，别有用
心的人非常容易就可以截获这些口令和数据。而且，这些服务程序的安全验证方式也是有其弱点的， 就是很容易受到“中
间人”（man-in-the-middle）这种方式的攻击。所谓“中间人”的攻击方式， 就是“中间人”冒充真正的服务器接收你传
给服务器的数据，然后再冒充你把数据传给真正的服务器。服务器和你之间的数据传送被“中间人”一转手做了手脚之后，
就会出现很严重的问题。通过使用SSH，你可以把所有传输的数据进行加密，这样"中间人"这种攻击方式就不可能实现了，
而且也能够防止DNS欺骗和IP欺骗。使用SSH，还有一个额外的好处就是传输的数据是经过压缩的，所以可以加快传输的速
度。SSH有很多功能，它既可以代替Telnet，又可以为FTP、PoP、甚至为PPP提供一个安全的"通道" 。

# 使用
SSH 的详细使用方法如下： 
ssh [-l login_name] [hostname | user@hostname] [command] ssh [-afgknqtvxCPX246] [-c blowfish | 3des] [-e escape_char] [-i identity_file] [-l login_name] [-o option] [-p port] [-L port:host:hostport] [-R port:host:hostport] [hostname | user@hostname] [command] 
sshd 
为执行 ssh 的 daemon，在读者使用 ssh 之前必须去激活 sshd，在此建议把它加在 /etc/init/rc.local 中，在每次开机时激活。 
在执行 sshd 之前可以指定它的 port，例如：sshd –p 999 
若有安装 SSL，可以指定 SSL 的 port 443，例如：sshd –p 443 
这样就可以经过 SSL 及 SSH 双重的保护，但必须去指明使用的 port 
ssh –l user –p 443 mouse.oit.edu.tw 才行，若不指明则仍然使用预设的port 22 
ssh 
### 选项： 
-l login_name 
指定登入于远程机器上的使用者，若没加这个选项，而直接打 ssh lost 也是可以的，它是以读者目前的使用者去做登入的动作。 例如： ssh –l shie mouse.oit.edu.tw 
-c blowfish|3des 
在期间内选择所加密的密码型式。预设是3des，3des(作三次的资料加密) 是用三种不同的密码键作三次的加密-解密-加密。 blowfish 是一个快速区块密码编制器，它比3des更安全以及更快速。 
-v 
Verbose 模式。使ssh 去印出关于行程的除错讯息，这在连接除错，认 证和设定的问题上有很的帮助。 
-V 
显示版本。 
-a 
关闭认证代理联机。 
-f 
要求ssh 在背景执行命令，假如ssh要询问密码或通行证，但是使用者 想要它在幕后执行就可以用这个方式，最好还是加上-l user 例如在远程场所上激活 X11，有点像是 ssh –f host xterm 。 
-e character 
设定跳脱字符。 
-g 
允许远程主机去连接本地指派的 ports。 
-i identity_file 
选择所读取的 RSA 认证识别的档案。预设是在使用者的家目录 中的 .ssh/identity 。 
-n 
重导 stdin 到 /dev/null (实际上是避免读取 stdin)。必须当 ssh 在幕后执 行时才使用。常见的招数是使用这选项在远程机器上去执行 X11 的程序 例如，ssh -n shadows.cs.hut.fi emacs &amp;，将在 shadows.cs.hut.fi 上激活 emace，并且 X11 连接将自动地在加密的信道上发送。ssh 程序将把它放 在幕后。(假如ssh需要去询问密码时，这将不会动作) 
-p port 
连接远程机器上的 port。 
-P 
使用非特定的 port 去对外联机。如果读者的防火墙不淮许从特定的 port去联机时，就可以使用这个选项。注意这个选项会关掉 RhostsAuthentication 和 RhostsRSAAuthentication。 
-q 
安静模式。把所有的警告和讯息抑制，只有严重的错误才会被显示。 
-t 
强制配置 pseudo-tty。这可以在远程机器上去执行任意的 screen-based 程 式，例如操作 menu services。 
-C 
要求压缩所有资料(包含 stdin, stdout,stderr 和 X11 和 TCP/IP 连接) 压缩演算规则与 gzip 相同，但是压缩的等级不能控制。在调制解调器或 联机速度很慢的地方，压缩是个很好的选择，但如果读者的网络速路很 快的话，速度反而会慢下来。 
-L listen-port:host:port 
指派本地的 port 到达端机器地址上的 port。 
-R listen-port:host:port 
指派远程上的 port 到本地地址上的 port。 
-2 强制 ssh 去使用协议版本 2。 
-4 强制 ssh 去使用 IPv4 地址。 
-6 强制 ssh 去使用 IPv6 地址。 

登录远程主机之后，经常会拷贝一些文件，可以使用[scp命名](https://github.com/YaowenGuo/LinuxNote/blob/master/file_transfer_scp.md)

使用该软件能够方便的拷贝文件，然而当一些远程主机没有开放SSH服务时，而是仅仅提供了ftp服务。它给出的资源地址将会变成ftp://ip/路径。这时候的路径
并不一定是一个绝对的地址，而可能是ftp服务提供的一个资源相对路径。这时候，我们就不能使用ssh登录，去查看文件的位置了。这时候使用ftp协议传输文件才
是一个明智的选择。
