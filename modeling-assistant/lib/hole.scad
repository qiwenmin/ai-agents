// lib/hole.scad — 公共孔模块
// 放在 z = 0 平面上方打孔，depth 默认穿透 100mm
module hole(x = 0, y = 0, d = 3, depth = 100, counterbore = 0, cb_depth = 3) {
  // counterbore > 0 时生成沉头孔（沉头直径由调用方用 d 推或自行扩展）
  translate([x, y, -0.01])
    cylinder(h = depth + 0.02, d = d);
}

module counterbore_hole(x = 0, y = 0, d = 3, cb_d = 0, cb_depth = 3, depth = 100) {
  // d      : 通孔直径
  // cb_d   : 沉头直径（0 = 普通孔）
  // cb_depth: 沉头深度
  union() {
    translate([x, y, -0.01]) cylinder(h = depth + 0.02, d = d);
    if (cb_d > d)
      translate([x, y, depth - cb_depth])
        cylinder(h = cb_depth + 0.01, d = cb_d);
  }
}

// 圆周孔阵: n 个孔均布在半径 r 上
module hole_circle(center_x = 0, center_y = 0, r = 20, n = 4, d = 3, depth = 100) {
  for (i = [0:n-1])
    hole(x = center_x + r * cos(i * 360 / n),
         y = center_y + r * sin(i * 360 / n),
         d = d, depth = depth);
}

// 简单倒角方块（用 minkowski + sphere）
module chamfered_box(size, c = 1) {
  minkowski() {
    scale([1,1,1]) {
      // 先生成略小的实体
      offset(delta = -c, center = true)
        translate([c,c,c]) box(size, center = [false,false,false]);
    }
    sphere(r = c, $fn = 24);
  }
}
