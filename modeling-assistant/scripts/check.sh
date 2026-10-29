#!/usr/bin/env bash
# check.sh — 只做语法/参数检查，不导出（快）
# 用法: ./scripts/check.sh models/xxx.scad [更多文件...]
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "用法: $0 <file.scad> [file.scad ...]" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
rc=0
for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: 文件不存在: $f" >&2
    rc=1
    continue
  fi
  echo "== 检查 $f =="
  if openscad -q --export-format=echo -o - "$f" >/dev/null 2>/tmp/openscad_check.err; then
    echo "OK (0 error)"
  else
    echo "FAILED:" >&2
    cat /tmp/openscad_check.err >&2
    rc=1
  fi
done
exit $rc
