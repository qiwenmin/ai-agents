// 003-m6-bolt.scad — M6 六角头螺栓，螺纹长度 18 mm
// 螺纹/头部几何由第三方库 BOSL2 (screws.scad) 按 ISO 标准生成：
//   - 螺纹: ISO 724 公制 60° 牙型，公称 M6 粗牙 P=1.0，含标准配合公差
//   - 头部: ISO 4014 六角头，对面宽 s=10，头高 k=4，顶面倒角
// 参数集中在下方，均可用 -D 覆盖，例如：
//   openscad -D L=25 -o out/x.stl models/003-m6-bolt.scad

include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>

/* [参数] */
M     = 6;      // 公称直径 mm
pitch = 1;      // 螺距 mm（M6 粗牙）
L     = 18;     // 螺杆长度 = 螺纹长度（全螺纹）mm
head  = "hex";  // 头型: "hex"=六角螺栓 / "socket"=内六角圆柱头 / "none"=无双头螺柱
$fn   = 64;     // 曲面细分

screw(str("M", M, "x", pitch, ",", L), head = head, thread = true);
