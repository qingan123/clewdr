#!/usr/bin/env bash
set -Eeuo pipefail

# Interactive SSH menu for install/update/status/logs/delete.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
while true; do
  clear 2>/dev/null || true
  printf 'ClewdR 管理菜单\n================\n1) 一键部署\n2) 更新到最新版\n3) 查看状态和密码\n4) 查看最近日志\n5) 删除实例\n0) 退出\n'
  read -r -p '请选择 [0-5]: ' choice
  case "$choice" in
    1) "$ROOT_DIR/clewdr-install.sh" ;;
    2) "$ROOT_DIR/clewdr-update.sh" ;;
    3) docker ps -a --filter name=clewdr --format 'table {{.Names}}\\t{{.Status}}\\t{{.Ports}}'; docker logs --tail 40 clewdr 2>&1 | grep -E 'API Password|Web Admin Password|Valid:|Invalid:|Exhausted:' || true ;;
    4) docker logs --tail 100 clewdr 2>&1 || true ;;
    5) "$ROOT_DIR/clewdr-delete.sh" ;;
    0) exit 0 ;;
    *) printf '无效选择。\n' ;;
  esac
  printf '\n按 Enter 返回菜单...'; read -r
 done
