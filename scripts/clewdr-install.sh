#!/usr/bin/env bash
set -Eeuo pipefail

# ClewdR interactive Docker installer
# Installs the official upstream image with persistent local data.

APP_NAME="${CLEWDR_CONTAINER:-clewdr}"
IMAGE="${CLEWDR_IMAGE:-ghcr.io/xerxes-2/clewdr:latest}"
DATA_DIR="${CLEWDR_DATA_DIR:-$HOME/.clewdr/data}"
DEFAULT_PORT="${CLEWDR_PORT:-8484}"

fail() { printf '错误：%s\n' "$*" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || fail '未找到 Docker，请先安装 Docker。'
docker info >/dev/null 2>&1 || fail 'Docker 不可用，请确认当前 SSH 用户有权限。'

printf 'ClewdR 一键部署\n================\n'
read -r -p "容器名称 [${APP_NAME}]: " input; APP_NAME="${input:-$APP_NAME}"
read -r -p "宿主机端口 [${DEFAULT_PORT}]: " HOST_PORT; HOST_PORT="${HOST_PORT:-$DEFAULT_PORT}"
[[ "$HOST_PORT" =~ ^[0-9]+$ ]] && (( HOST_PORT >= 1 && HOST_PORT <= 65535 )) || fail '端口必须是 1-65535 的数字。'
read -r -p "数据目录 [${DATA_DIR}]: " input; DATA_DIR="${input:-$DATA_DIR}"

if docker ps -a --format '{{.Names}}' | grep -Fxq "$APP_NAME"; then
  fail "容器 $APP_NAME 已存在。需要更新请运行 clewdr-update.sh。"
fi

read -r -s -p '管理员密码（留空自动生成）: ' ADMIN_PASSWORD; printf '\n'
read -r -s -p 'API 密钥（留空自动生成）: ' API_PASSWORD; printf '\n'
mkdir -p "$DATA_DIR"
chmod 700 "$DATA_DIR"

# Do not put empty values into the container environment: ClewdR generates them.
ENV_ARGS=(-e CLEWDR_IP=0.0.0.0)
[[ -n "$ADMIN_PASSWORD" ]] && ENV_ARGS+=(-e "CLEWDR_ADMIN_PASSWORD=$ADMIN_PASSWORD")
[[ -n "$API_PASSWORD" ]] && ENV_ARGS+=(-e "CLEWDR_PASSWORD=$API_PASSWORD")

docker pull "$IMAGE"
docker run -d --name "$APP_NAME" --restart unless-stopped \
  -p "${HOST_PORT}:8484" -v "${DATA_DIR}:/etc/clewdr" \
  "${ENV_ARGS[@]}" "$IMAGE" >/dev/null

sleep 2
if ! docker ps --format '{{.Names}}' | grep -Fxq "$APP_NAME"; then
  docker logs --tail 80 "$APP_NAME" || true
  fail '容器启动失败。'
fi

printf '\n部署完成。\n管理地址：http://<服务器IP>:%s/\nAPI 地址：http://<服务器IP>:%s/v1\n\n密码（仅从日志读取，避免回显输入内容）：\n' "$HOST_PORT" "$HOST_PORT"
docker logs "$APP_NAME" 2>&1 | grep -E 'API Password|Web Admin Password|v[0-9]' | tail -n 3
printf '\n数据目录：%s\n更新：./scripts/clewdr-update.sh\n删除：./scripts/clewdr-delete.sh\n' "$DATA_DIR"
