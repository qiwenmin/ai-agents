// models/001-bracket.scad — 示例：L 型支架，带 4 个安装孔
// 用法: ./scripts/build.sh models/001-bracket.scad png
include <../lib/hole.scad>

// ===== 参数区 =====
a_len  = 60;   // 底臂长度
a_w    = 40;   // 底臂宽度
b_len  = 40;   // 立臂长度
t      = 8;    // 板厚
f_hole_d  = 5; // 安装孔直径
f_cb_d    = 9; // 沉头直径
f_cb_depth= 4; // 沉头深度
// ==================

echo("bracket: $a_len x $a_w x $b_len, t=$t");

difference() {
  union() {
    // 底臂
    translate([0, 0, 0])
      cube([a_len, a_w, t], center = [false, false, false]);
    // 立臂
    translate([a_len - t, 0, 0])
      cube([t, a_w, b_len], center = [false, false, false]);
  }
  // 底臂安装孔（沉头从顶面朝下）
  counterbore_hole(x = 10, y = a_w/2, d = f_hole_d, cb_d = f_cb_d, cb_depth = f_cb_depth, depth = t);
  counterbore_hole(x = a_len - 10, y = a_w/2, d = f_hole_d, cb_d = f_cb_d, cb_depth = f_cb_depth, depth = t);
}
