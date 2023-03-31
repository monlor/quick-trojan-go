## 介绍

使用docker一键搭建trojan-go，使用caddy自动生成证书

## 使用

* vps开通443/tcp,443/udp,80/tcp端口
* 将你的域名解析到vps服务器
* 修改下面命令中的DOMAIN和PASSWORD变量，在VPS上执行

```bash
docker volume create trojan_data
docker run -d \
  --name trojan \
  -p 80:80/tcp \
  -p 443:443/tcp \
  -p 443:443/udp \
  -e DOMAIN=你的域名 \
  -e PASSWORD=trojan的访问密码 \
  -v trojan_data:/root/.local/share/caddy \
  --restart unless-stopped \
  monlor/quick-trojan-go:main
```

另外，如果你还没有安装docker，执行下面的命令一键安装

```bash
curl -sSL https://get.docker.com/ | sh
```

## 参考

[trojan-caddy-docker-compose](https://github.com/FaithPatrick/trojan-caddy-docker-compose)