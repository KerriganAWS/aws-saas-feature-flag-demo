# AWS SaaS Feature Flag Demo

这个项目演示了如何使用 Flagsmith 开源特性标志服务在 AWS 上部署一个完整的特性标志管理解决方案。

## 架构概览

该演示使用以下 AWS 服务：

- **Amazon ECS (Elastic Container Service)** - 运行 Flagsmith 后端服务
- **Amazon S3** - 托管前端静态文件
- **Amazon CloudFront** - 提供全球内容分发
- **Elastic Load Balancing** - 为 Flagsmith API 提供负载均衡

## 演示功能

本演示展示了特性标志的三个主要用例：

1. **渐进式发布** - 逐步向一小部分用户推出新功能
2. **A/B 测试** - 对不同用户群展示不同版本的功能来测试效果
3. **即时功能控制** - 无需重新部署即可开启或关闭功能

## 部署说明

### 前提条件

- AWS CLI 已安装并配置
- 具有适当权限的 AWS 账户
- bash 或兼容的 shell 环境

### 部署步骤

1. 克隆此仓库：
   ```bash
   git clone https://github.com/aws-samples/aws-saas-feature-flag-demo.git
   cd aws-saas-feature-flag-demo
   ```

2. 运行设置脚本：
   ```bash
   chmod +x *.sh
   ./setup.sh --region us-east-1  # 可以指定任何有效的 AWS 区域
   ```

3. 部署完成后，您将获得：
   - CloudFront 分发的 URL（用于访问前端）
   - ALB 的 URL（用于访问 Flagsmith 管理界面）

### 更新部署

如果您需要更新部署，只需再次运行相同的命令：

```bash
./setup.sh --region us-east-1  # 使用与初始部署相同的区域
```

脚本会检测现有资源并更新它们，而不是重新创建。

### 配置 Flagsmith

1. 访问 Flagsmith 管理界面 (http://YOUR_ALB_DNS)
2. 创建一个新的项目和环境
3. 创建以下特性标志：
   - `progressive_release` - 渐进式发布示例
   - `button_color` - A/B 测试示例（值：blue 或 green）
   - `maintenance_mode` - 即时功能控制示例
4. 配置特性标志的规则（如百分比发布、用户分段等）
5. 获取环境 ID 并更新前端应用中的配置

## 文件结构

- `setup.sh` - 主设置脚本
- `deploy.sh` - 部署脚本
- `create-iam-role.sh` - 创建 IAM 角色
- `create-frontend-resources.sh` - 创建 S3 存储桶
- `create-cloudfront.sh` - 创建 CloudFront 分发
- `create-frontend-files.sh` - 准备前端文件
- `frontend/` - 前端演示应用程序文件
- `cleanup.sh` - 清理资源脚本

## 清理资源

要删除所有创建的资源，请运行：

```bash
./cleanup.sh
```

## 安全性

请注意，此演示项目配置为允许公共访问以便于演示。在生产环境中，您应该实施适当的安全措施，如：

- 使用 HTTPS
- 实施适当的身份验证和授权
- 限制网络访问
- 使用 AWS Secrets Manager 存储敏感信息

## 许可证

此示例代码遵循 MIT-0 许可证。详见 LICENSE 文件。
