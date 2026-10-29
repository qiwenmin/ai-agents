#!/usr/bin/env bash
# build.sh — 导出 STL（可选附带 PNG 预览），产物放 out/
# 用法:
#   ./scripts/build.sh models/xxx.scad            # 只出 STL
#   ./scripts/build.sh models/xxx.scad png        # STL + PNG 预览
#   ./scripts/build.sh models/xxx.scad png L=120 hole_d=8   # 叠加 -D 参数覆盖
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "用法: $0 <file.scad> [png] [K=V ...]" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
src="$1"; shift
mode="stl"
[ $# -ge 1 ] && [ "$1" = "png" ] && { mode="both"; shift; }

# 剩余参数视为 K=V，转成 -D
d_args=()
for kv in "$@"; do
  if [[ "$kv" != *=* ]]; then
    echo "ERROR: 参数应为 K=V 形式: $kv" >&2
    exit 2
  fi
  d_args+=("-D" "$kv")
done

mkdir -p out
base="$(basename "$src" .scad)"

echo "== 检查 $src =="
openscad -q --export-format=echo -o - "${d_args[@]}" "$src" >/dev/null || { echo "检查未通过，终止导出" >&2; exit 1; }

echo "== 导出 out/${base}.stl =="
openscad -q --export-format=binstl "${d_args[@]}" -o "out/${base}.stl" "$src"

if [ "$mode" = "both" ]; then
  echo "== 导出 out/${base}.png (preview) =="
  openscad -q --imgsize=1600,1200 "${d_args[@]}" -o "out/${base}.png" "$src"
fi

echo "完成: out/${base}.stl$([ "$mode" = both ] && echo " + out/${base}.png")"
