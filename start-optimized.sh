#!/bin/bash
# Uptime Kuma 优化启动脚本 - 适用于低配服务器

echo "🚀 启动 Uptime Kuma（优化模式）"

# 限制 Node.js 内存使用 (128MB)
export NODE_OPTIONS="--max-old-space-size=128"

# 设置生产环境
export NODE_ENV=production

# 减少日志输出
export UPTIME_KUMA_LOG_LEVEL=warn

echo "⚙️ 配置信息:"
echo "  - Node.js 内存限制: 128MB"
echo "  - 环境: production"
echo "  - 日志级别: warn"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到 Node.js"
    echo "请先安装 Node.js >= 20.4.0"
    exit 1
fi

NODE_VERSION=$(node --version)
echo "✅ Node.js 版本: $NODE_VERSION"

# 检查必要文件
if [ ! -f "server/server.js" ]; then
    echo "❌ 错误: 未找到 server/server.js"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

if [ ! -d "dist" ]; then
    echo "⚠️  警告: 未找到 dist 目录"
    echo "正在下载预构建前端资源..."
    npm run download-dist || {
        echo "❌ 下载失败，请手动运行: npm run download-dist"
        exit 1
    }
fi

echo ""
echo "🎉 启动服务..."
echo "访问地址: http://localhost:3001"
echo ""

# 启动服务
node server/server.js
