# openssh

使用ssh-keygen可以生成RSA、RSA1、DSA、ECDSA、ED25519等方式的密钥对。而使用openssl也可以完成这些。

这里我通过自己生成https证书，解决本地开发绑定的域名不支持https的问题。或者也可以在服务器上绑定申请的证书。

## 自己生成证书测试

PEM(Privacy Enhanced Mail) 是一种旨在将二进制内容转换为 ASCII 表示的格式。OpenSSH 使用的 PEM 其实是 Base64 编码的二进制内容。再加上开始和结束行，如证书文件的。

```
-----BEGIN CERTIFICATE-----
公钥内容
-----END CERTIFICATE-----
```

之所以添加开始行和结束行，是因为证书其实就是一系列 RAS 公钥的集合。用开始行和结束行进行分割。


1. 生成 rsa 秘钥

```shell
openssl genrsa -des3 -out key.pem 2048 
```

这个命令会生成一个2048位的密钥，同时有一个des3方法加密的密码，如果你不想要每次都输入密码，可以改成： 
openssl genrsa -out key.pem 2048 

建议用2048位密钥，少于此可能会不安全或很快将不安全。 

- `genras` 用于生成 `rsa` 算法的秘钥。
- `des3` 要求输入一个 `des3` 方法加密的密码。


2. 生成证书请求。(自签名可以跳过这一步)

证书请求是用于向数字证书颁发机构（即CA) 申请数字证书的文件。需要使用自己的秘钥生成。

```shell
openssl req -new -key key.pem -out cert.csr 
```

这个命令将会生成一个证书请求文件`cert.csr`，生成证书请求需要提供前面生成的密钥 `key.pem`。你可以拿着这个文件去数字证书颁发机构（即CA）申请一个数字证书。CA会给你一个新的文件cert.pem，那才是你的数字证书。

3. 生成证书

证书就是一个一些列机构的公钥加上你自己的公钥，如果自签名证书，则只有自己私钥对应的公钥。

如果是自己做测试，那么证书的申请机构和颁发机构都是自己。就可以用下面这个命令来生成证书： 

```shell
openssl req -new -x509 -key key.pem -out cert.pem -days 1024 
```

这个命令将用上面生成的密钥 key.pem 生成一个数字证书 cert.pem。

> 这里有个问题，为什么向 CA 申请证书提供的是 `cert.cst`，而自己生成却是 `key.pem`？

这是因为所谓证书，就是认证公钥而已。证书签发机构其实也是用他们自己的私钥生成对你公钥的签名。然后将你的公钥和他们签名的公钥放到 `cert.pem` 中。如果他们的证书不能电脑的根证书识别，需要再添加他们自己公钥的上一级机构的公钥签名。一直到公钥能被你电脑上的根证书识别为止。

上面命令创建的使用出错，[具体解决问题](https://stackoverflow.com/questions/21397809/create-a-trusted-self-signed-ssl-cert-for-localhost-for-use-with-express-node)

```
> openssl req -x509 -newkey rsa:2048 -keyout keytmp.pem -out cert.pem -days 365

> openssl rsa -in keytmp.pem -out key.pem
```

