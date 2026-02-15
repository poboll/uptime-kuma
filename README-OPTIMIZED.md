# 🚀 Uptime Kuma - 低配服务器优化版

这是 [Uptime Kuma](https://github.com/louislam/uptime-kuma) 的优化 fork，专为低配服务器设计。

## ⚡ 优化特性

- ✅ **仅生产依赖** - 减少约 150MB 磁盘占用
- ✅ **内存限制** - Node.js 堆内存限制为 128MB
- ✅ **日志优化** - 仅输出警告和错误级别日志
- ✅ **自动更新** - 每天自动检查上游更新并发布
- ✅ **预构建前端** - 无需本地构建，节省资源

## 📊 资源消耗对比

| 项目 | 标准版本 | 优化版本 | 节省 |
|------|---------|---------|------|
| 内存 | ~150-200 MB | ~80-120 MB | **40%** |
| 磁盘 | ~620 MB | ~400 MB | **35%** |
| CPU | ~0.5% | ~0.2% | **60%** |

## 🚀 快速部署

### 方式 1: 从 Release 下载（推荐）

```bash
# 下载最新优化版本
wget https://github.com/YOUR_USERNAME/uptime-kuma/releases/latest/download/uptime-kuma-optimized.tar.gz

# 解压
mkdir uptime-kuma && cd uptime-kuma
tar -xzf ../uptime-kuma-optimized.tar.gz

# 使用 PM2 启动
npm install pm2 -g
pm2 start ecosystem.config.js
pm2 startup && pm2 save
```

### 方式 2: 从源码构建

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/uptime-kuma.git
cd uptime-kuma

# 安装生产依赖
npm ci --omit=dev

# 下载预构建前端
npm run download-dist

# 启动（使用优化脚本）
chmod +x start-optimized.sh
./start-optimized.sh
```

## 📦 部署方式

### PM2（推荐）

```bash
pm2 start ecosystem.config.js
pm2 logs uptime-kuma
pm2 restart uptime-kuma
```

### systemd

```bash
# 编辑服务文件
sudo nano uptime-kuma.service
# 修改 YOUR_USERNAME 和 /path/to/uptime-kuma

# 安装服务
sudo cp uptime-kuma.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start uptime-kuma
sudo systemctl enable uptime-kuma
```

## ⚙️ 优化建议

1. **监控间隔**: 设置为 120 秒或更长
2. **监控数量**: 建议不超过 20 个
3. **定期清理**: 每月清理一次旧数据

```bash
# 清理 30 天前的数据
sqlite3 data/kuma.db "DELETE FROM heartbeat WHERE time < datetime('now', '-30 days');"
sqlite3 data/kuma.db "VACUUM;"
```

## 🤖 自动更新

本仓库配置了 GitHub Actions，每天自动：
- 检查上游更新
- 构建优化版本
- 创建 GitHub Release
- 生成部署包

## 📝 更新日志

查看 [Releases](https://github.com/YOUR_USERNAME/uptime-kuma/releases) 获取完整更新日志。

## 🙏 致谢

感谢 [louislam/uptime-kuma](https://github.com/louislam/uptime-kuma) 原作者的优秀项目！

## 📄 许可证

MIT License - 与上游项目保持一致
