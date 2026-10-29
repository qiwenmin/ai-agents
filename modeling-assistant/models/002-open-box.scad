// 002-open-box.scad  无盖盒子（四根竖直棱圆角）
// 外尺寸：长 L x 宽 W x 高 H（mm），壁厚 t，顶面开口，竖直棱圆角半径 r
// 可调参数：openscad -D L=120 -D W=100 -D H=50 -D t=1.5 -D r=5 ...

L = 100;  // 长（X 方向，外径）
W = 80;   // 宽（Y 方向，外径）
H = 40;   // 高（Z 方向，整体外径）
t = 1.2;  // 壁厚
r = 5;    // 竖直棱圆角半径（需 r < min(L,W)/2；r > t 时内角也为圆角，r < t 时内角为直角）

// 圆弧细分：$fa 越小圆角越光滑（单位：度，0 = 最平滑但面片更多）
$fa = 1;
$fs = 0.2;

// 2D 圆角矩形（以中心为原点，宽 w x h，圆角 rad）
// 技巧：缩小的方块做 offset(rad) 外扩 → 角部自动变圆
module rrect(w, h, rad) {
  offset(rad) square([w - 2*rad, h - 2*rad], center = true);
}

difference() {
  // 外形：圆角矩形截面 + 竖直拉伸
  linear_extrude(height = H)
    rrect(L, W, r);

  // 内空腔：缩进 t 的圆角矩形，从 z=t 起向上穿透顶面 → 无盖
  translate([0, 0, t])
    linear_extrude(height = H)
      rrect(L - 2*t, W - 2*t, r - t);
}
