
## Context

`flutter run -d windows` 在 desktop_app 上失败，报两类错误：

1. **desktop_app.dart 语法错误** — `=>` 被 cmd.exe shell 重定向截断，导致 `builder: (ctx, state, child) => DesktopShell(...)` 变成 `builder: (ctx, state, child) = child)`。
2. **NinjaTheme 未找到** — 导入了 `ui_kit/ninja_theme/ninja_theme.dart`（只含 NinjaColors/NinjaTextStyles 等），应导入 `ui_kit/ninja_theme/theme_data.dart`（含 class NinjaTheme）。
3. **Isar SchemaSchema 未定义** — `packages/core` 中的 5 个 schemas 缺少 `build_runner` 生成的 `.g.dart` 文件。

## Approach

### 1. 修复 desktop_app.dart（3 项修改）

- **修改导入**：`ninja_theme.dart` → `theme_data.dart`
- **修复 ShellRoute builder**：`(ctx, state, child) => DesktopShell(child: child)`
- **修复 NavigationRail onDestinationSelected**：`(i) => _navigate(context, i)`
- 确保全部字符串用单引号，避免 shell 转义问题

### 2. 生成 Isar .g.dart 文件

在 `packages/core` 中运行：
```
dart pub get
dart run build_runner build --delete-conflicting-outputs
```
此操作需在修复 desktop_app.dart 后且 flutter 构建前执行。

### 3. 验证

```
cd apps/desktop_app
flutter pub get
flutter clean
flutter run -d windows
```

## Key Files

| 文件 | 修改内容 |
|------|---------|
| `apps/desktop_app/lib/app/desktop_app.dart` | 修正导入（第 4 行）；重构 ShellRoute builder（第 52 行）及 NavigationRail onDestinationSelected（第 73 行）；添加缺失括号/const |
| 生成 `packages/core/lib/storage/isar/schemas/*.g.dart` | 运行 build_runner |

## Risks & Open Questions

- Isar 代码生成器版本需与 pubspec.yaml 中的 `isar` 版本匹配
- `ui_kit` 中 `theme_data.dart` 对 `ninja_theme.dart` 存在循环导入（`theme_data.dart` 第 2 行导入了 `ninja_theme.dart`），但在导入 `theme_data.dart` 时是安全的，因为 Dart 顶层声明加载顺序可处理这一情况
