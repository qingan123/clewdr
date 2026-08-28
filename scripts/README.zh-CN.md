# ClewdR SSH 部署脚本说明

这个 Fork 提供 **3 个独立脚本**，分别负责部署、更新和卸载。脚本文件已经放在你的 GitHub 仓库中，部署服务器时需要先从你的仓库下载项目，再执行脚本。

## 第一步：从你的 GitHub 仓库下载

```bash
git clone https://github.com/qingan123/clewdr.git
cd clewdr
```

如果服务器没有安装 Git，可以使用下面的方式下载压缩包：

```bash
curl -L https://github.com/qingan123/clewdr/archive/refs/heads/master.tar.gz -o clewdr.tar.gz
tar -xzf clewdr.tar.gz
cd clewdr-master
```

## 第二步：执行脚本

不需要先执行 `chmod`，直接使用 `bash` 执行即可：

```bash
bash scripts/clewdr-install.sh
```

如果希望使用 `./` 方式执行，才需要先授权：

```bash
chmod +x scripts/clewdr-install.sh scripts/clewdr-update.sh scripts/clewdr-delete.sh
./scripts/clewdr-install.sh
```

## 三个脚本

### 部署

```bash
bash scripts/clewdr-install.sh
```

第一次部署使用。脚本会检查 Docker；如果服务器没有 Docker，会先询问是否执行 Docker 官方安装脚本。然后交互设置容器名称、宿主机端口、数据目录、管理员密码和 API 密钥。

### 更新

```bash
bash scripts/clewdr-update.sh
```

更新官方 ClewdR 镜像，保留端口、数据目录、Cookie、管理员密码和 API 密钥。

### 卸载

```bash
bash scripts/clewdr-delete.sh
```

交互选择只删除容器，或者同时删除数据目录。彻底删除数据需要二次确认。

## 前提条件

服务器需要能联网，并且当前 SSH 用户是 root 或拥有 sudo 权限。部署脚本只在你确认后才会安装 Docker。
