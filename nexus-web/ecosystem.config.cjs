module.exports = {
  apps: [
    {
      name: 'joeltom-web',
      script: 'dist/server/index.js',
      cwd: '/opt/joeltom-web',
      env: {
        NODE_ENV: 'production',
        PORT: '2087',
        JOELTOM_DB_DIR: '/etc/joeltom-web',
        NEXUS_ADMIN_USER: 'admin',
        NEXUS_ADMIN_PASS: 'admin',
        NEXUS_JWT_SECRET: 'change-me'
      },
      autorestart: true,
      watch: false,
      max_restarts: 10,
      restart_delay: 3000
    }
  ]
};
