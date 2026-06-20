# Word Ninja（忍者英语）

基于 Flutter 全平台开发的 AI 英语学习工具，通过「忍者修炼 + RPG成长 + AI老师」模式，让用户在游戏化体验中完成英语学习。

> 不再是背单词，而是培养一名英语忍者。

## 技术栈

| 层级 | 技术 |
|------|------|
| 跨平台 UI | Flutter 3.35+ |
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 本地数据库 | Isar |
| AI 能力 | OpenAI API (GPT-4o) + STT/TTS |

## 快速开始

```bash
# 安装依赖
dart pub get

# 运行移动端
cd apps/mobile_app && flutter run

# 运行桌面端
cd apps/desktop_app && flutter run

# 运行管理后台
cd apps/admin_panel && flutter run
```

## 项目结构

详见 [docs/Architecture/frontend.md](docs/Architecture/frontend.md)
