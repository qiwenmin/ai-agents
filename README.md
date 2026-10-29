# ai-agents

多个 AI agent 子项目的集合（monorepo）。每个子项目一个顶层目录，围绕一个具体场景
定义 agent 的工作流（`AGENTS.md`）与技能（子目录内 `.agents/skills/`，[Agent Skills](https://agentskills.io/specification) 开放标准）。

## 子项目

| 子项目 | 说明 |
|---|---|
| [modeling-assistant](modeling-assistant/) | OpenSCAD 3D 建模助手：文字需求 → `.scad` 模型 → 编译校验 → 导出 STL / PNG |

## modeling-assistant（建模助手）

用自然语言描述零件需求（尺寸、孔位、倒角等，单位 mm），agent 生成
[OpenSCAD](https://openscad.org/) 代码，编译验证后导出可 3D 打印的 STL 与 PNG 预览。

- 工作流说明：[modeling-assistant/AGENTS.md](modeling-assistant/AGENTS.md)
- 技能定义（Agent Skills 标准，pi / opencode 通用）：[SKILL.md](modeling-assistant/.agents/skills/openscad-modeling/SKILL.md)

### 依赖

- OpenSCAD ≥ 2021.01，命令行可用（`openscad --version`）
- 遵循 AGENTS.md 约定、且能发现 `.agents/skills/` 的编码代理（实测 pi 与 opencode 均支持；技能随子项目存放，需在对应子目录内启动）

### 使用

```bash
cd modeling-assistant

# 语法/参数检查（快，不导出）
./scripts/check.sh models/001-bracket.scad

# 导出 STL 到 out/；可选附带 PNG 预览、-D 参数覆盖
./scripts/build.sh models/001-bracket.scad png
./scripts/build.sh models/001-bracket.scad png a_len=80 f_hole_d=6
```

模型关键尺寸集中在 `.scad` 文件顶部的参数区；改尺寸优先改参数或用 `-D` 覆盖，
不动几何代码。

### 目录结构（modeling-assistant/）

```
models/   每个建模需求一个 NNN-描述.scad 文件
lib/      公共模块（孔、沉头、孔阵等），include 引入
scripts/  check.sh（校验）、build.sh（导出 STL/PNG）
out/      导出产物，可随时删除重建（已 gitignore）
```

## 新增子项目约定

- 一个子项目一个顶层目录，目录内自带 `AGENTS.md`（agent 工作流）与 `.gitignore`
- 可复用资源（模块库、脚本）放子项目内的 `lib/`、`scripts/`，跨子项目不共享
- 新子项目在上表「子项目」中登记一行
- 新子项目的技能放该子项目内 `.agents/skills/<skill-name>/SKILL.md`，`name` 与目录名一致，遵循 Agent Skills 规范

## 许可证

[MIT](LICENSE) © BG1REN
