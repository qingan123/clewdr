#!/usr/bin/env bash
set -Eeuo pipefail

# ClewdR interactive Docker updater. Persistent data is kept.
APP_NAME="${CLEWDR_CONTAINER:-clewdr}"
IMAGE="${CLEWDR_IMAGE:-ghcr.io/xerxes-2/clewdr:latest}"

fail() { printf '错误：%s\n' "$*" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || fail '未找到 Docker。'
docker inspect "$APP_NAME" >/dev/null 2>&1 || fail "容器 $APP_NAME 不存在。"

printf '将更新 %s 到 %s。Cookie、密码和数据目录会保留。\n' "$APP_NAME" "$IMAGE"
read -r -p '确认更新？输入 yes 继续: ' answer
[[ "$answer" == yes ]] || { printf '已取消。\n'; exit 0; }

mapfile -t port_args < <(docker inspect "$APP_NAME" --format '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{(index $conf 0).HostPort}}:{{$p}}{{end}}{{end}}' | sed 's#/tcp##')
mapfile -t volume_args < <(docker inspect "$APP_NAME" --format '{{range .Mounts}}{{.Source}}:{{.Destination}}{{"\n"}}{{end}}')
mapfile -t env_args < <(docker inspect "$APP_NAME" --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^CLEWDR_' || true)
((${#port_args[@]})) || fail '无法读取原容器端口映射。'
((${#volume_args[@]})) || fail '无法读取数据卷映射，为安全起见停止更新。'

docker pull "$IMAGE"
docker rm -f "$APP_NAME" >/dev/null
docker run -d --name "$APP_NAME" --restart unless-stopped \
  $(printf -- '-p %q ' "${port_args[@]}") \
  $(printf -- '-v %q ' "${volume_args[@]}") \
  $(printf -- '-e %q ' "${env_args[@]}") "$IMAGE" >/dev/null

sleep 2
docker ps --format '{{.Names}}' | grep -Fxq "$APP_NAME" || { docker logs --tail 80 "$APP_NAME" || true; fail '更新后容器未正常运行。'; }
printf '更新完成，当前镜像：%s\n' "$(docker inspect "$APP_NAME" --format '{{.Config.Image}}')"
