#!/bin/bash
# Word Ninja 环境配置脚本
# 使用国内镜像加速 Flutter/Dart 包下载
#
# 用法: source scripts/env.sh

export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 将 pub 缓存 bin 目录加入 PATH（melos 等工具安装在此）
export PATH="$PATH":"$HOME/.pub-cache/bin"

echo "✅ 已配置国内镜像:"
echo "   PUB_HOSTED_URL=$PUB_HOSTED_URL"
echo "   FLUTTER_STORAGE_BASE_URL=$FLUTTER_STORAGE_BASE_URL"
echo "   PATH 已包含 ~/.pub-cache/bin"
