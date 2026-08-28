#!/usr/bin/env bash
set -Eeuo pipefail

# ClewdR interactive remover. Data is never removed unless explicitly requested.
APP_NAME="${CLEWDR_CONTAINER:-clewdr}"
DATA_DIR="${CLEWDR_DATA_DIR:-$HOME/.clewdr/data}"

if ! command -v docker >/dev/null 2>&1; then printf '错误：未找到 Docker。\n' >&2; exit 1; fi
if ! docker inspect "$APP_NAME" >/dev/null 2>&1; then printf '容器 %s 不存在。\n' "$APP_NAME"; exit 0; fi

printf '删除选项：\n1) 删除容器，保留 Cookie/密码/配置（推荐）\n2) 删除容器并删除数据目录（不可恢复）\n3) 取消\n'
read -r -p '请选择 [1-3]: ' choice
case "$choice" in
  1)
    read -r -p "确认删除容器 $APP_NAME？输入 DELETE: " answer
    [[ "$answer" == DELETE ]] || { printf '已取消。\n'; exit 0; }
    docker rm -f "$APP_NAME" >/dev/null
    printf '容器已删除，数据保留在 Docker 挂载目录中。\n'
    ;;
  2)
    read -r -p "将永久删除 $APP_NAME 和 $DATA_DIR，输入 DELETE DATA: " answer
    [[ "$answer" == 'DELETE DATA' ]] || { printf '已取消。\n'; exit 0; }
    docker rm -f "$APP_NAME" >/dev/null
    if [[ -n "$DATA_DIR" && "$DATA_DIR" != / && -d "$DATA_DIR" ]]; then rm -rf -- "$DATA_DIR"; fi
    printf '容器和数据目录已删除。\n'
    ;;
  3) printf '已取消。\n' ;;
  *) printf '无效选择。\n' >&2; exit 2 ;;
esac
