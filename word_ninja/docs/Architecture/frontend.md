# 前端架构文档

## 技术栈

- **框架**: Flutter 3.35+
- **状态管理**: Riverpod 2.x
- **路由**: GoRouter
- **本地数据库**: Isar 3.x
- **UI**: Ninja Theme（忍者主题）

## 架构模式

采用 **Feature First + Clean Architecture**：

```
presentation/  ← UI 层（页面/组件/Provider）
domain/        ← 领域层（实体/用例/接口）
data/          ← 数据层（数据源/模型/仓库实现）
```

## 模块依赖

```
mobile_app
  ├─ auth        → core + ui_kit
  ├─ vocabulary  → core + ui_kit
  ├─ reading     → core + ui_kit
  ├─ ai          → core
  ├─ ai_tutor    → core + ui_kit + ai
  ├─ listening   → core + ui_kit
  ├─ speaking    → core + ui_kit
  ├─ writing     → core + ui_kit + ai
  ├─ study_plan  → core + ai
  ├─ achievement → core + ui_kit
  ├─ shop        → core + ui_kit
  ├─ leaderboard → core + ui_kit
  ├─ profile     → core + ui_kit
  ├─ sync        → core
  └─ common_widgets → core + ui_kit
```

## 数据流

```
UI (Widget)
  ↓ watch/read
Riverpod Provider
  ↓ call
Repository (Interface)
  ↓
RepositoryImpl
  ├─ LocalDataSource (Isar)
  └─ RemoteDataSource (Dio + Go API)
```
