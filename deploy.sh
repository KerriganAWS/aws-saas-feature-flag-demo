#!/bin/bash
# deploy.sh

# 检查必要的工具
command -v aws >/dev/null 2>&1 || { echo "需要安装 AWS CLI"; exit 1; }

# 设置变量
if [ -f .aws-region ]; then
    REGION=$(cat .aws-region)
else
    REGION="us-east-1"  # 默认区域
    echo $REGION > .aws-region
fi

STACK_NAME="flagsmith-demo"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始部署 Flagsmith 演示环境...${NC}"
echo "使用区域: $REGION"

# 确保 IAM 角色存在
bash create-iam-role.sh

# 1. 创建 S3 和 CloudFront 资源（如果不存在）
if [ ! -f .bucket-name ]; then
    echo -e "${YELLOW}创建前端资源...${NC}"
    bash create-frontend-resources.sh "$REGION"
    bash create-cloudfront.sh "$REGION"
else
    echo "使用现有的前端资源"
fi

BUCKET_NAME=$(cat .bucket-name)
CLOUDFRONT_DIST_ID=$(cat .distribution-id)

# 2. 更新前端文件并部署到 S3
echo -e "${YELLOW}更新前端文件...${NC}"

# 更新 API 端点
bash create-frontend-files.sh

# 上传前端文件到 S3
echo "上传前端文件到 S3: $BUCKET_NAME"
aws s3 sync frontend/ s3://$BUCKET_NAME/ --delete --region $REGION --content-type "text/html; charset=utf-8" --exclude "*" --include "*.html"
aws s3 sync frontend/ s3://$BUCKET_NAME/ --delete --region $REGION --content-type "text/css; charset=utf-8" --exclude "*" --include "*.css"
aws s3 sync frontend/ s3://$BUCKET_NAME/ --delete --region $REGION --content-type "application/javascript; charset=utf-8" --exclude "*" --include "*.js"
aws s3 sync frontend/ s3://$BUCKET_NAME/ --delete --region $REGION --exclude "*.html" --exclude "*.css" --exclude "*.js"

# 3. 创建 CloudFront 缓存失效
echo "创建 CloudFront 缓存失效"
aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_DIST_ID \
  --paths "/*"

# 4. 输出访问信息
CLOUDFRONT_DOMAIN=$(cat .cloudfront-domain)

echo -e "${GREEN}部署完成!${NC}"
echo -e "${GREEN}前端访问地址: https://$CLOUDFRONT_DOMAIN${NC}"
echo ""
echo "请在 Flagsmith 管理界面创建以下特性标志:"
echo "1. progressive_release - 渐进式发布示例"
echo "2. button_color - A/B 测试示例 (值: blue 或 green)"
echo "3. maintenance_mode - 即时功能控制示例"
