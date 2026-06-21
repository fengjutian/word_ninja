#!/bin/bash
# Word Ninja 开发脚本
# 用法: bash scripts/run.sh [command]

COMMAND=${1:-help}

case "$COMMAND" in
  mobile)
    cd apps/mobile_app && flutter run -d "$2"
    ;;
  desktop)
    cd apps/desktop_app && flutter run -d "$2"
    ;;
  admin)
    cd apps/admin_panel && flutter run -d "$2"
    ;;
  analyze)
    flutter analyze lib/
    for pkg in packages/*/; do
      (cd "$pkg" && flutter analyze lib/)
    done
    ;;
  test)
    flutter test
    for pkg in packages/*/; do
      (cd "$pkg" && flutter test)
    done
    ;;
  clean)
    flutter clean
    for pkg in packages/*/; do
      (cd "$pkg" && flutter clean)
    done
    for app in apps/*/; do
      (cd "$app" && flutter clean)
    done
    ;;
  gen)
    # 运行代码生成（freezed / json_serializable）
    # 先 pub get 确保依赖就绪
    for pkg in core auth vocabulary ai ai_tutor reading listening speaking writing; do
      if [ -d "packages/$pkg" ]; then
        (cd "packages/$pkg" && dart pub get && dart run build_runner build --delete-conflicting-outputs)
      fi
    done
    ;;
  bootstrap)
    dart pub global activate melos
    export PATH="$PATH":"$HOME/.pub-cache/bin"
    melos bootstrap
    ;;
  help|*)
    echo "Word Ninja 开发工具"
    echo ""
    echo "用法: bash scripts/run.sh <command> [options]"
    echo ""
    echo "命令:"
    echo "  mobile [device]  运行移动端"
    echo "  desktop [device] 运行桌面端"
    echo "  admin  [device]  运行管理后台"
    echo "  analyze          代码分析"
    echo "  test             运行测试"
    echo "  clean            清理构建"
    echo "  gen              生成代码（freezed）"
    echo "  bootstrap        Melos 初始化"
    ;;
esac
