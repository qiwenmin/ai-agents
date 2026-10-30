---
name: openscad-modeling
description: 根据用户的自然语言需求编写 OpenSCAD 模型，编译检查，导出 STL，并生成 PNG 预览验证。适用于"帮我做个法兰/支架/齿轮/盒子"这类 3D 建模请求。
license: MIT
compatibility: Requires the openscad CLI (2021.01+). Work inside the modeling-assistant/ directory of this repository.
---

# OpenSCAD 建模技能

工作目录是仓库根下的 `modeling-assistant/`，下文所有相对路径与命令都在该目录内执行。
完整工作流与目录约定见仓库中 `modeling-assistant/AGENTS.md`。

用户给出文字需求 → 你在 `models/` 下生成 `.scad` 文件 → 检查 → 导出 → 预览验证。

## 标准流程

1. **需求 → 参数表**：先把文字拆成尺寸表（mm）。缺的关键尺寸先假设默认值并注明。
2. **写代码**：
   ```scad
   // 顶部集中参数，支持 -D 覆盖
   L = 100;  // 总长
   W = 60;   // 总宽
   t = 10;   // 板厚
   hole_d = 6;

   include <../lib/hole.scad>

   difference() {
     cube([L, W, t], center = [0, 0, false]);   // 本机不支持 box()，用 cube()
     for (p = hole_positions)  hole(x=p[0], y=p[1], d=hole_d);
   }
   ```
3. **检查**（必须通过才能交付）：
   ```bash
   openscad -q --export-format=echo -o - models/xxx.scad   # 0 error 才算通过
   ```
   WARN 可以保留但最好修掉；报错按 stderr 行号定位。
4. **导出**：
   ```bash
   openscad -o out/xxx.stl models/xxx.scad 2>out/xxx.log
   ```
5. **预览验证**：
   ```bash
   openscad -o out/xxx.png --imgsize=1200,900 models/xxx.scad
   ```
   然后用 `read` 打开 PNG 目检：外形比例、孔位、有无明显布尔错误。
6. **汇报**：给出文件路径 + 参数说明 + 修改建议（"想加大孔径就改 `hole_d` 或
   `openscad -D hole_d=8 ...`"）。

## 常用命令（OpenSCAD 2021.01, `-o` 为必需，否则启动 GUI）

| 场景 | 命令 |
|---|---|
| 语法/参数检查 | `openscad -q --export-format=echo -o - file.scad` |
| 导出 STL | `openscad -o out.stl file.scad` |
| 二进制 STL | `openscad --export-format=binstl -o out.stl file.scad` |
| 覆盖参数 | `openscad -D L=120 -o out.stl file.scad` |
| PNG 预览 | `openscad -o out.png --imgsize=1600,1200 file.scad` |
| 指定视角 | `--camera=tx,ty,tz,rx,ry,rz,dist`（如 `15,15,20,35,0,0,120`） |
| 高质量渲染 | `--render`（PNG 用；默认 preview 更快但可能有接缝） |
| 动画帧 | `--animate=N` |
| 依赖文件 | `-d deps.make` |
| 静默模式 | `-q`（只打印错误） |

可选导出格式：`stl off amf 3mf dxf svg png`（由输出扩展名决定）。

## 写模型的技巧

- **避免用 `box()`**：本机构建没有该模块，用 `cube()` 代替。

- **开孔/凹槽（切刀超出量）**：`difference()` 的切刀严禁与实体表面共面——
  共面会导致 preview 出现条纹/z-fighting，布尔结果不确定。切刀沿**穿透方向**
  外扩一个微小超出量 `eps`，标注尺寸的定位面保持精确：
  ```scad
  eps = 0.01;  // 微小超出量（0.01~0.05 均可），只加在穿透方向
  difference() {
    cube([L, W, t]);
    // 通孔：上下各超出 eps；孔位/孔径保持精确
    translate([x, y, -eps]) cylinder(d=hole_d, h=t + 2*eps);
    // 贯穿侧壁的槽：壁厚方向两侧外扩；槽宽/槽底保持精确
    translate([-eps, y0, z0]) cube([t + 2*eps, w, h + eps]);
  }
  ```
- **拼接（union）不要恰好贴合**：布尔操作数要么充分重叠、要么明确分离，与切刀
  同一条原则。贴合拼接 CGAL 能干净融合（接触面成内部面被删，实测与重叠拼接
  产物相同），但接触坐标只要差 ≥1e-6（表达式/三角函数推导的浮点误差）就会
  **静默裂成两片壳**——0 error、STL 照常导出、preview 看不出，切片时才暴露。
  正确做法是体积重叠/深埋，重叠量无需精确：
  ```scad
  union() {
    cube([L, W, t]);   // 底板
    cube([tw, W, H]);  // 立墙从 Z=0 长到顶、深埋进底板；不要 translate 到板面再放
  }
  ```
  自检：`openscad -o x.stl` 统计里实心单件应 `Volumes: 2`（外空间+实体）；
  无内腔却出现 3 = 裂件（002 那类带空腔的除外）。
- **沉头孔**：两个同心圆柱相减（大径浅 + 小径深）。
- **阵列**：`for (x = [a:(step):b]) translate([x,0,0]) feature();`
- **圆周阵列**：
  ```scad
  for (i = [0:n-1]) rotate([0,0,i*360/n]) translate([r,0,0]) feature();
  ```
- **光滑度**：`$fn = max(24, ceil(直径/0.4));` 直径越大 fn 越大。
- **多面体/复杂曲面**：优先用 `minkowski()`、旋转体 `rotate_extrude()`、
  `linear_extrude()` + DXF 轮廓（`import()`）。
- **齿轮**：可手搓（`polygon` + `offset`）或用现成 `gear.scad`（Boing）
  放进 `lib/`。
- **文字**：`import("text.scad")` 需要 freetype 字体文件；没有字体就跳过 3D 文字，
  用 DXF 或提示用户。
- **性能**：避免 `hull()` 包住很多高 `fn` 圆柱的组合运算；
  大阵列先合并再布尔。

## 验证清单（交付前逐项确认）

- [ ] `openscad -q --export-format=echo -o -` 0 error
- [ ] STL 文件已生成且大小 > 0
- [ ] PNG 预览目检通过（比例、孔位、无缺块、槽/孔内面无共面条纹）
- [ ] 所有尺寸可在文件顶部参数区一处修改
- [ ] 向用户说明了参数含义和如何用 `-D` 快速改尺寸
