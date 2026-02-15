module.exports = {
  apps: [{
    name: 'uptime-kuma',
    script: 'server/server.js',
    instances: 1,
    exec_mode: 'fork',

    // 内存限制 - 超过 150MB 自动重启
    max_memory_restart: '150M',

    // Node.js 参数 - 限制堆内存为 128MB
    node_args: '--max-old-space-size=128',

    // 环境变量
    env: {
      NODE_ENV: 'production',
      UPTIME_KUMA_LOG_LEVEL: 'warn'
    },

    // 日志配置（限制大小）
    error_file: 'logs/error.log',
    out_file: 'logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    merge_logs: true,

    // 日志轮转（需要 pm2-logrotate 模块）
    // 安装: pm2 install pm2-logrotate
    // 配置: pm2 set pm2-logrotate:max_size 10M

    // 自动重启配置
    autorestart: true,
    watch: false,
    max_restarts: 10,
    min_uptime: '10s',
    restart_delay: 4000,

    // 优雅关闭
    kill_timeout: 5000,
    wait_ready: true,
    listen_timeout: 10000,

    // 时间配置
    time: true
  }]
};
