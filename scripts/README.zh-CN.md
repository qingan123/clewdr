# ClewdR 交互式 Docker 脚本

脚本适合 SSH 服务器使用，默认使用官方 `ghcr.io/xerxes-2/clewdr:latest` 镜像，并把 `/etc/clewdr` 持久化到宿主机。

## 使用

```bash
chmod +x scripts/clewdr-*.sh
./scripts/clewdr-menu.sh
```

也可以直接执行：

```bash
./scripts/clewdr-install.sh   # 交互选择容器名、端口、数据目录、管理员密码、API 密钥
./scripts/clewdr-update.sh    # 拉取最新版并重建，保留数据和原端口/密码
./scripts/clewdr-delete.sh    # 交互删除容器，可选择是否删除数据
```

## 安全说明

- 密码使用隐藏输入；留空时由 ClewdR 自动生成。
- 更新脚本会从现有容器读取端口、挂载目录和 `CLEWDR_*` 配置，避免更新后丢 Cookie 或改密码。
- 删除默认只删除容器，不删除数据；删除数据必须输入 `DELETE DATA`。
- 脚本不会自动修改 UFW。若要公网访问，请由管理员明确放行所选端口，例如 `sudo ufw allow 8484/tcp`。
- 不建议把管理后台直接暴露到公网；最好使用防火墙限制来源或已有 HTTPS 入口。
