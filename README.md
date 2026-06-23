# Word Ninja（忍者英语）

> 不再是背单词，而是培养一名英语忍者。

**Word Ninja** 是一款基于 Flutter 全平台开发的 AI 英语学习工具，通过「忍者修炼 + RPG 成长 + AI 老师」模式，让用户在游戏化体验中完成英语学习。

支持 **Android、iOS、Windows、macOS、Linux** 全平台。

---

## 核心理念

```
传统模式：背单词 → 遗忘 → 放弃
忍者模式：学习 → 获得经验 → 升级 → 解锁技能 → 获得奖励 → 持续学习
```

### 等级体系

| 等级 | 称号 |
|------|------|
| Lv1 | 学徒龟 |
| Lv10 | 下忍 |
| Lv20 | 中忍 |
| Lv30 | 上忍 |
| Lv40 | 精英忍者 |
| Lv50 | 忍者大师 |
| Lv80 | 影级大师 |
| Lv100 | 英语传奇 |

---

## 功能模块

- **词汇修炼** — 单词卡片、拼写挑战、听音选词、忍者对战
- **阅读训练** — AI 生成文章、PDF/EPUB/TXT 阅读、划词翻译、AI 长难句解析
- **听力训练** — AI 分级听力课程（N1–N5）、听写训练
- **口语训练** — AI 发音评测、情景对话
- **写作训练** — AI 批改、语法纠错
- **AI 导师** — 个性化学习计划、实时答疑、语音对话
- **成就系统** — 忍者等级、勋章、称号、排行榜
- **多端同步** — 学习进度云端同步

---

## 技术栈

| 层级 | 技术 |
|------|------|
| 跨平台 UI | Flutter 3.35+ |
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 本地数据库 | Isar |
| 后端 | Go |
| 数据库 | PostgreSQL |
| AI | OpenAI 兼容 API（GPT-4o）+ STT / TTS |
| Monorepo 管理 | Melos |

---

## 项目结构

```
word_ninja/
├── apps/               # 应用入口
│   ├── mobile_app/     # Android / iOS
│   ├── desktop_app/    # Windows / macOS / Linux
│   └── admin_panel/    # Flutter Web 管理后台
├── packages/           # 功能模块包
│   ├── core/           # 核心基础设施
│   ├── ui_kit/         # 通用 UI 组件
│   ├── auth/           # 认证
│   ├── ai/             # AI 能力封装
│   ├── vocabulary/     # 词汇修炼
│   ├── reading/        # 阅读训练
│   ├── listening/      # 听力训练
│   ├── speaking/       # 口语训练
│   ├── writing/        # 写作训练
│   ├── study_plan/     # 学习计划
│   ├── achievement/    # 成就系统
│   ├── profile/        # 用户中心
│   └── sync/           # 数据同步
├── server/             # Go 后端服务
├── docs/               # 项目文档
├── scripts/            # 构建/部署脚本
├── pubspec.yaml        # 根 pubspec
└── melos.yaml          # Melos monorepo 配置
```

---

## 快速开始

### 环境要求

- Flutter SDK >= 3.5.0
- Go >= 1.22
- PostgreSQL >= 15

### 安装依赖

```bash
# 安装 Melos
dart pub global activate melos

# 引导所有包
cd word_ninja
melos bootstrap
```

### 运行应用

```bash
# 移动端
cd apps/mobile_app && flutter run

# 桌面端
cd apps/desktop_app && flutter run

# 管理后台
cd apps/admin_panel && flutter run
```

### 启动后端

```bash
cd server
go run cmd/api/main.go
```

### 运行测试

```bash
melos test
```

---

## 文档

- [产品需求文档](需求.md)
- [技术架构设计](技术.md)
- [项目文档](word_ninja/docs/)

---

## License

MIT
