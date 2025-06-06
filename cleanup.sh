#!/bin/bash
# cleanup.sh

# 获取区域参数
if [ -f .aws-region ]; then
    REGION=$(cat .aws-region)
else
    REGION="us-east-1"  # 默认区域
fi

# 设置变量
STACK_NAME="flagsmith-demo"

# 颜色输出
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始清理 Flagsmith 演示环境资源...${NC}"
echo "使用区域: $REGION"

# 1. 删除 CloudFront 分发
if [ -f .distribution-id ]; then
    DISTRIBUTION_ID=$(cat .distribution-id)
    echo "禁用 CloudFront 分发..."
    
    # 获取当前配置和 ETag
    aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --query "DistributionConfig" > dist-config.json
    ETAG=$(aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --query "ETag" --output text)
    
    # 修改配置以禁用分发
    sed -i '' 's/"Enabled": true/"Enabled": false/' dist-config.json
    
    # 更新分发
    aws cloudfront update-distribution --id $DISTRIBUTION_ID --distribution-config file://dist-config.json --if-match $ETAG
    
    echo "等待 CloudFront 分发禁用并部署完成..."
    
    # 等待分发状态变为 Deployed
    while true; do
        STATUS=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query "Distribution.Status" --output text 2>/dev/null || echo "")
        if [ "$STATUS" == "Deployed" ]; then
            break
        fi
        echo "CloudFront 分发状态: $STATUS，继续等待..."
        sleep 30
    done
    
    # 删除分发
    echo "删除 CloudFront 分发..."
    ETAG=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query "ETag" --output text 2>/dev/null || echo "")
    if [ -n "$ETAG" ] && [ "$ETAG" != "None" ]; then
        aws cloudfront delete-distribution --id $DISTRIBUTION_ID --if-match $ETAG
        echo "CloudFront 分发已删除"
    fi
fi

# 2. 删除 Origin Access Control
if [ -f .oac-id ]; then
    OAC_ID=$(cat .oac-id)
    echo "删除 CloudFront Origin Access Control..."
    aws cloudfront delete-origin-access-control --id $OAC_ID --if-match "*"
fi

# 3. 删除 S3 存储桶
if [ -f .bucket-name ]; then
    BUCKET_NAME=$(cat .bucket-name)
    echo "清空并删除 S3 存储桶..."
    aws s3 rm s3://$BUCKET_NAME --recursive --region $REGION
    aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION
    echo "S3 存储桶已删除"
fi

# 4. 删除临时文件
echo "删除临时文件..."
rm -f .bucket-name .distribution-id .cloudfront-domain .aws-region .oac-id bucket-policy.json dist-config.json trust-policy.json cloudfront-config.json 2>/dev/null || true

echo -e "${RED}清理完成!${NC}"
