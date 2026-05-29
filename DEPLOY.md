# 零基础 Docker 部署指南

本文说明如何把「富集分析气泡图 / 条形图」平台部署到**已安装 Docker 的 Linux 服务器**上。  
你不需要在服务器上单独安装 Node.js 或 R——Docker 会在构建镜像时自动装好。

---

## 一、先搞懂要做什么（3 句话）

1. 把你的项目文件夹**上传到服务器**。
2. 在项目根目录执行 **`docker compose up -d --build`**（第一次会很久，因为要下载并编译 R 生信环境）。
3. 浏览器打开 **`http://你的服务器IP`** 就能用网站；绘图请求会由容器里的 R 服务处理。

---

## 二、你需要提前准备什么

| 项目 | 说明 |
|------|------|
| 一台云服务器 | 阿里云 / 腾讯云 / 华为云等，系统建议 **Ubuntu 22.04** 或 **CentOS 7+** |
| 公网 IP | 控制台里能看到，例如 `123.45.67.89` |
| 已安装 Docker | 见下文「安装 Docker」 |
| 服务器配置 | 建议 **2 核 CPU、4GB 内存、20GB 磁盘** 及以上（R + 富集分析较吃内存） |
| 项目代码 | 你电脑上的整个 `enrichment-bubble-tool` 文件夹 |

本地开发用的 `Rscript run_api.R`、Vite 开发服务器**部署时不用开**，全部由 Docker 代替。

---

## 三、在服务器上安装 Docker（只做一次）

用 SSH 登录服务器（下面以 Ubuntu 为例）。

### 3.1 登录服务器

- **Windows**：可用 [PuTTY](https://www.putty.org/)，或用 PowerShell：
  ```powershell
  ssh root@你的服务器IP
  ```
- 输入密码后，提示符类似 `root@xxx:~#` 即表示已登录。

### 3.2 安装 Docker（Ubuntu 官方脚本）

在服务器上**逐行**执行：

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
curl -fsSL https://get.docker.com | sudo sh
sudo systemctl enable docker
sudo systemctl start docker
```

验证是否成功：

```bash
docker --version
docker compose version
```

若能看到版本号（例如 `Docker version 26.x`、`Docker Compose version v2.x`），说明安装成功。

> **CentOS 用户**：可同样执行 `curl -fsSL https://get.docker.com | sudo sh`，或查阅云厂商「Docker 安装」文档。

---

## 四、把项目上传到服务器

任选一种方式即可。

### 方式 A：用 Git（推荐，若代码在 GitHub/Gitee）

在服务器上：

```bash
cd /opt
sudo git clone 你的仓库地址 enrichment-bubble-tool
cd enrichment-bubble-tool
```

### 方式 B：用 WinSCP / FileZilla（适合没有 Git）

1. 在电脑上安装 [WinSCP](https://winscp.net/)。
2. 新建连接：主机名 = 服务器 IP，用户名 `root`，密码 = 云厂商给的密码。
3. 把整个 **`enrichment-bubble-tool`** 文件夹拖到服务器的 `/opt/enrichment-bubble-tool`（路径可自定，记住即可）。
4. SSH 登录后进入该目录：
   ```bash
   cd /opt/enrichment-bubble-tool
   ```

上传后，目录里应能看到：

- `docker-compose.yml`
- `backend/`、`frontend/`、`deploy/`

---

## 五、一键构建并启动（核心步骤）

在**项目根目录**（有 `docker-compose.yml` 的那一层）执行：

```bash
cd /opt/enrichment-bubble-tool   # 改成你的实际路径
sudo docker compose up -d --build
```

### 第一次会发生什么？

| 阶段 | 大概时间 | 说明 |
|------|----------|------|
| 下载 Node、Nginx 镜像 | 1–5 分钟 | 构建前端 |
| `npm ci` + `npm run build` | 2–5 分钟 | 打包网页 |
| 下载 R 镜像并安装 Bioconductor | **15–40 分钟** | 最慢，请耐心等待 |
| 启动两个容器 | 几秒 | `backend` + `web` |

查看是否在构建/运行：

```bash
sudo docker compose ps
```

正常时类似：

```
NAME                          STATUS    PORTS
enrichment-bubble-tool-web-1       running   0.0.0.0:80->80/tcp
enrichment-bubble-tool-backend-1   running   8787/tcp
```

查看实时日志（排错时用）：

```bash
# 全部日志
sudo docker compose logs -f

# 只看 R 后端
sudo docker compose logs -f backend

# 只看网页
sudo docker compose logs -f web
```

按 `Ctrl + C` 退出日志查看（不会停止服务）。

---

## 六、开放防火墙 / 安全组（否则外网打不开）

### 6.1 云厂商「安全组」

在阿里云 / 腾讯云控制台找到该服务器的**安全组**，添加入站规则：

- 协议：**TCP**
- 端口：**80**
- 来源：`0.0.0.0/0`（仅内网测试可填内网段）

### 6.2 服务器本机防火墙（若有）

Ubuntu（ufw）：

```bash
sudo ufw allow 80/tcp
sudo ufw reload
```

---

## 七、验证是否部署成功

### 7.1 健康检查（API）

在**你自己电脑**的浏览器打开：

```
http://你的服务器IP/api/health
```

若看到一段 JSON，里面有 `"ok": true`，说明后端正常。

### 7.2 打开网站

```
http://你的服务器IP
```

应能看到富集分析页面；可点「示例」上传测试。

### 7.3 在服务器上自测（可选）

```bash
curl -s http://127.0.0.1/api/health
```

---

## 八、日常运维命令（收藏即可）

```bash
cd /opt/enrichment-bubble-tool

# 停止
sudo docker compose down

# 重新构建并启动（改代码后）
sudo docker compose up -d --build

# 只重启，不重新构建
sudo docker compose restart

# 查看占用磁盘
sudo docker system df
```

---

## 九、更新网站（你改了代码之后）

1. 把新代码同步到服务器（重新 `git pull` 或 WinSCP 覆盖）。
2. 在项目根目录执行：
   ```bash
   sudo docker compose up -d --build
   ```

---

## 十、常见问题

### Q1：`docker compose` 提示 command not found

试：

```bash
sudo docker compose version
```

若仍没有，安装插件：

```bash
sudo apt-get install -y docker-compose-plugin
```

### Q2：构建 backend 时网络超时 / 失败

- 多试几次 `sudo docker compose up -d --build`。
- 确认服务器能访问外网（R 需从 CRAN / Bioconductor 下载包）。
- 内存不足会导致编译失败，请升级到 4GB 内存。

### Q3：网页能开，但画图一直失败

1. 看后端日志：`sudo docker compose logs -f backend`
2. 确认 `/api/health` 可访问。
3. 首次富集分析需联网下载注释，等待时间可能较长（与本地开发相同）。

### Q4：80 端口已被占用

编辑项目根目录 `docker-compose.yml`，把：

```yaml
ports:
  - "80:80"
```

改成例如：

```yaml
ports:
  - "8080:80"
```

然后访问 `http://服务器IP:8080`，并记得在安全组放行 **8080**。

### Q5：想用域名 + HTTPS

需要域名解析到服务器 IP，并额外配置 Nginx 证书或 Caddy。  
当前 `docker-compose` 仅提供 HTTP 80 端口；HTTPS 可后续再加一层反向代理。

---

## 十一、目录与架构说明（可选阅读）

```
浏览器 → web 容器 (Nginx:80)
           ├─ 静态网页 ← frontend 构建的 dist
           └─ /api/*  → backend 容器 (R Plumber:8787)
```

- `deploy/nginx.conf`：把 `/api` 转发到 R 服务。
- `backend/Dockerfile`：安装 R 与生信依赖。
- `deploy/Dockerfile.web`：用 Node 构建前端，再用 Nginx 提供服务。

---

## 十二、部署检查清单

- [ ] 服务器已安装 Docker，`docker compose version` 有输出
- [ ] 项目已上传到服务器，且含 `docker-compose.yml`
- [ ] 已执行 `sudo docker compose up -d --build` 且无报错结束
- [ ] `docker compose ps` 两个服务均为 `running`
- [ ] 安全组已放行 80（或你改的端口）
- [ ] 浏览器能打开 `http://IP/api/health` 和首页
- [ ] 能加载示例并完成一次作图

若某一步失败，把 **`docker compose logs backend`** 最后 30 行截图发给维护者即可排查。
