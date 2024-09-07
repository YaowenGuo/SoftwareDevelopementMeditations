# Charles 抓取 htpps 包

三点需要注意：

1. 系统安装根证书，并设置为总是信任：Help -> SSL Proxying -> Intall Charles Root Sertificate.

2. 手机安装证书：手机 wifi 设置代理后，浏览器输入：chls.pro/ssl 下载，保存的文件放到 Download 目录下方便查找。
    各个手机安装证书的方式不同，可以根据手机厂商网上搜索如何安装 CA 证书。
    鸿蒙手机使用命令安装：hdc shell aa start -a MainAbility -b com.ohos.certmanager

3. 安卓 APP 需要应用内配置允许自签名证书。鸿蒙目前 debug 包默认就能使用自签名证书。
