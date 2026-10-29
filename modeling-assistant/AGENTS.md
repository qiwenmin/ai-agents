# 建模助手项目说明（AGENTS.md）

本项目是一个 **OpenSCAD 3D 建模工作区**。用户的角色是提出建模需求（文字描述），
你的角色是：把需求翻译成 OpenSCAD 代码 → 编译验证 → 导出 STL / PNG 预览 → 交付。

## 工作方式

1. **理解需求**：明确零件的尺寸（mm）、孔位（孔径/位置/沉头/通孔/盲孔）、倒角、
   材质无关的几何特征。需求不明确时，先给出你的假设并列出待确认项，再继续。
2. **编写代码**：
   - 模型文件放入 `models/`，命名为 `NNN-描述.scad`（如 `001-gear-adapter.scad`）。
   - 可复用的结构（孔、沉头、加强筋、倒角模块）抽到 `lib/` 下，用 `include` 引入。
   - 关键参数集中放在文件顶部（`L = 100; // 总长`），方便后续用 `-D` 覆盖修改。
   - 代码内注释用中文说明关键尺寸和几何逻辑。
3. **编译验证**（必须做，不要跳过）：
   ```bash
   ./scripts/check.sh models/xxx.scad   # 语法/AST 检查，快
   ```
   报错时根据 stderr 中的行号修复，直到 0 error。真正的几何导出由 build.sh 兜底。
4. **导出交付物**：
   ```bash
   ./scripts/build.sh models/xxx.scad           # 导出 STL（放 out/）
   ./scripts/build.sh models/xxx.scad png       # 同时生成 PNG 预览
   ```
5. **视觉验证**：生成 PNG 后用 `read` 查看预览图，确认结构符合需求
   （孔没打穿、比例正确、没有自相交导致的渲染异常），不对就改代码重新导出。
6. **交付**：告知用户 STL/PNG 路径、关键尺寸参数、以及"改哪些参数"能微调。

## 目录约定

```
models/   用户需求的模型（每个需求一个 .scad 文件）
lib/      公共模块库（孔位、倒角、筋条等）
out/      导出产物（STL / PNG / 3MF），可随时删除重建
scripts/  构建辅助脚本
```

## OpenSCAD 命令速查（本机 2021.01，已实测）

| 用途 | 命令 |
|------|------|
| 仅检查，不输出 | `openscad -q --export-format=echo -o - file.scad`（echo 打到 stdout） |
| 导出 STL | `openscad -o out.stl file.scad`（二进制加 `--export-format=binstl`） |
| 覆盖参数 | `openscad -D L=120 -D hole_d=8 -o out.stl file.scad` |
| PNG 预览 | `openscad -o out.png --imgsize=1600,1200 file.scad` |
| 全渲染 PNG | 加 `--render`（慢但准确；默认 preview 更快但可能有接缝） |
| 指定视角 | `--camera=tx,ty,tz,rx,ry,rz [dist]`，可配合 `--autocenter --viewall` |
| 依赖文件 | `-d deps.make`（Makefile 语法，可用于增量构建） |

注意：
- 不带 `-o` 会启动 GUI，**永远**带 `-o`。
- 导出格式由扩展名决定（stl / off / amf / 3mf / dxf / svg / png）；输出到 stdout/非文件目标时需 `--export-format=...` + `-o -`。
- **本机 build 不支持 `box()`**（会警告 unknown module），写模型时一律用 `cube()` 替代。
- **本机 build 不支持 `-o null`**，用 `--export-format=echo -o -`（或 scripts/check.sh）代替。
- 复杂模型编译慢属正常；若卡在 boolean 运算，提醒用户可用 `--preview` 快速看效果。

## 代码风格（OpenSCAD）

- 模块命名 `snake_case`，参数用有意义的名字并给默认值：
  `module hole(d=3, depth='through', x=0, y=0) { ... }`
- 开孔用 `difference()`，组合用 `union()` / `intersection()`。
- 圆角/光滑曲面注意 `$fn`（或模块内 `$fn = max(24, ceil(d/0.5));`），
  STL 太糙会打不出光滑弧线。
- 避免过深的递归和超大 `for` 展开，编译会指数级变慢。

## 硬性要求

- 不要伪造"编译通过"——必须真的跑过 `check.sh` 并且 0 error。
- 每次交付的 STL/代码必须能独立编译（lib 依赖用相对路径 `include`）。
- 单位一律 mm。
