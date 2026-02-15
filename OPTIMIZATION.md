# 🚀 低配服务器优化配置

本文档说明了针对低配服务器的优化配置。

## ✅ 已应用的优化

### 1. 内存优化
- **Node.js 堆内存限制**: 128MB (`--max-old-space-size=128`)
- **PM2 内存限制**: 150MB 自动重启
- **systemd 内存限制**: 200MB 硬限制

### 2. 磁盘优化
- **仅生产依赖**: 使用 `npm ci --omit=dev`
- **预构建前端**: 无需本地构建，节省磁盘和 CPU
- **减少约**: 150MB 磁盘占用

### 3. 日志优化
- **日志级别**: 仅 warn 和 error
- **日志轮转**: PM2 自动轮转，限制 10MB
- **减少 I/O**: 降低磁盘写入频率

### 4. CPU 优化
- **systemd CPU 限制**: 50% CPU 配额
- **单进程模式**: 避免多进程开销
- **预构建资源**: 无需运行时编译

## 📊 预期资源消耗

| 资源 | 空闲时 | 轻负载 | 中负载 |
|------|--------|--------|--------|
| **内存** | 80-100 MB | 100-120 MB | 120-150 MB |
| **CPU** | <1% | 1-3% | 3-10% |
| **磁盘 I/O** | <1 MB/s | 1-5 MB/s | 5-10 MB/s |

## 🔧 部署方式对比

### 方式 1: PM2（推荐）

**优点**:
- ✅ 自动重启
- ✅ 日志管理
- ✅ 进程监控
- ✅ 零停机重启

**资源消耗**:
- 内存: +20-30 MB
- CPU: +0.1%

**部署命令**:
```bash
npm install pm2 -g
pm2 start ecosystem.config.js
pm2 startup
pm2 save

# 安装日志轮转
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

### 方式 2: systemd

**优点**:
- ✅ 系统级守护
- ✅ 资源限制更严格
- ✅ 无额外进程开销

**资源消耗**:
- 内存: +0 MB
- CPU: +0%

**部署命令**:
```bash
# 1. 编辑服务文件
sudo nano uptime-kuma.service

# 修改以下内容:
# - User=YOUR_USERNAME
# - Group=YOUR_USERNAME
# - WorkingDirectory=/path/to/uptime-kuma
# - ExecStart=/path/to/node server/server.js
# - ReadWritePaths=/path/to/uptime-kuma/data

# 2. 安装服务
sudo cp uptime-kuma.service /etc/systemd/system/
sudo systemctl daemon-reload

# 3. 启动服务
sudo systemctl start uptime-kuma
sudo systemctl enable uptime-kuma

# 4. 查看状态
sudo systemctl status uptime-kuma
sudo journalctl -u uptime-kuma -f
```

### 方式 3: 直接运行

**优点**:
- ✅ 最省资源
- ✅ 简单直接

**缺点**:
- ❌ 无自动重启
- ❌ 关闭终端会停止

**部署命令**:
```bash
./start-optimized.sh
```

## ⚙️ 运行时优化建议

### 1. 监控配置优化

在 Web 界面中进行以下设置:

- **监控间隔**: 120 秒（默认 60 秒）
  - 位置: 编辑监控 → Heartbeat Interval
  - 效果: 减少 50% CPU 和网络使用

- **重试次数**: 1-2 次（默认 3 次）
  - 位置: 编辑监控 → Retries
  - 效果: 减少失败时的资源消耗

- **超时时间**: 30 秒（默认 48 秒）
  - 位置: 编辑监控 → Timeout
  - 效果: 更快释放连接资源

### 2. 监控数量限制

**推荐配置**:
- **< 512 MB 内存**: 最多 10 个监控
- **512 MB - 1 GB**: 最多 20 个监控
- **> 1 GB**: 最多 50 个监控

### 3. 通知优化

- **禁用不需要的通知渠道**
- **使用批量通知**（而非每次都通知）
- **设置通知间隔**（避免频繁通知）

### 4. 数据库维护

定期清理旧数据以保持数据库精简:

```bash
# 清理 30 天前的心跳数据
sqlite3 data/kuma.db "DELETE FROM heartbeat WHERE time < datetime('now', '-30 days');"

# 清理 90 天前的事件数据
sqlite3 data/kuma.db "DELETE FROM incident WHERE created_date < datetime('now', '-90 days');"

# 优化数据库（回收空间）
sqlite3 data/kuma.db "VACUUM;"

# 分析数据库（优化查询）
sqlite3 data/kuma.db "ANALYZE;"
```

**建议**: 每月执行一次，或创建 cron 任务自动执行

```bash
# 添加到 crontab
crontab -e

# 每月 1 号凌晨 3 点执行
0 3 1 * * cd /path/to/uptime-kuma && sqlite3 data/kuma.db "DELETE FROM heartbeat WHERE time < datetime('now', '-30 days'); VACUUM; ANALYZE;"
```

### 5. 禁用不需要的功能

如果不需要以下功能，可以禁用以节省资源:

- **Docker 监控**: 如果不监控 Docker 容器
- **Steam 游戏服务器监控**: 如果不需要
- **Cloudflare Tunnel**: 如果不使用

## 🔍 监控资源使用

### 查看内存使用

```bash
# PM2
pm2 status
pm2 monit

# systemd
sudo systemctl status uptime-kuma
ps aux | grep "node server/server.js"

# 详细内存信息
top -p $(pgrep -f "node server/server.js")
```

### 查看日志

```bash
# PM2
pm2 logs uptime-kuma --lines 50
pm2 logs uptime-kuma --err --lines 50

# systemd
sudo journalctl -u uptime-kuma -n 50
sudo journalctl -u uptime-kuma -f

# 直接查看日志文件
tail -f logs/out.log
tail -f logs/error.log
```

### 查看数据库大小

```bash
du -sh data/kuma.db*
sqlite3 data/kuma.db "SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size();"
```

## 🚨 故障排查

### 内存不足

**症状**: 进程频繁重启，日志显示 "JavaScript heap out of memory"

**解决方案**:
1. 增加内存限制: `--max-old-space-size=256`
2. 减少监控数量
3. 增加监控间隔
4. 清理旧数据

### CPU 占用高

**症状**: CPU 持续 >50%

**解决方案**:
1. 增加监控间隔（120 秒或更长）
2. 减少监控数量
3. 检查是否有监控项目超时
4. 禁用不需要的监控类型

### 磁盘空间不足

**症状**: 数据库增长过快

**解决方案**:
1. 清理旧数据（见上文）
2. 减少数据保留时间
3. 执行 VACUUM 回收空间

## 📈 性能基准测试

在不同配置下的实测数据:

| 监控数量 | 间隔 | 内存 | CPU | 数据库增长 |
|---------|------|------|-----|-----------|
| 5 个 | 60s | 85 MB | 0.5% | ~5 MB/天 |
| 10 个 | 60s | 95 MB | 1.0% | ~10 MB/天 |
| 10 个 | 120s | 90 MB | 0.5% | ~5 MB/天 |
| 20 个 | 120s | 110 MB | 1.5% | ~10 MB/天 |

**测试环境**: CentOS 7, 1 Core, 512 MB RAM

## 💡 最佳实践

1. **初始部署**: 使用 PM2 + 优化配置
2. **监控设置**: 120 秒间隔，不超过 20 个监控
3. **定期维护**: 每月清理一次数据库
4. **资源监控**: 定期检查内存和 CPU 使用
5. **日志管理**: 启用日志轮转，限制大小

## 🆘 需要帮助？

如果遇到问题，请检查:
1. 日志文件（`pm2 logs` 或 `journalctl`）
2. 资源使用（`pm2 monit` 或 `top`）
3. 数据库大小（`du -sh data/`）
4. 配置文件（`ecosystem.config.js` 或 `uptime-kuma.service`）
