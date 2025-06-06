#!/bin/bash
# create-frontend-resources.sh

# 获取区域参数
if [ -n "$1" ]; then
    REGION="$1"
elif [ -f .aws-region ]; then
    REGION=$(cat .aws-region)
else
    REGION="us-east-1"  # 默认区域
fi

echo "使用区域: $REGION"

# 检查是否已存在 S3 存储桶
if [ -f .bucket-name ]; then
    BUCKET_NAME=$(cat .bucket-name)
    echo "使用现有的 S3 存储桶: $BUCKET_NAME"
else
    # 创建 S3 存储桶
    BUCKET_NAME="flagsmith-demo-frontend-$(date +%s)"
    echo "创建 S3 存储桶: $BUCKET_NAME"
    
    # 创建存储桶
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
          --bucket $BUCKET_NAME \
          --region $REGION
    else
        aws s3api create-bucket \
          --bucket $BUCKET_NAME \
          --region $REGION \
          --create-bucket-configuration LocationConstraint=$REGION
    fi
    
    # 阻止公共访问
    aws s3api put-public-access-block \
      --bucket $BUCKET_NAME \
      --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
      --region $REGION
    
    echo "S3 存储桶已创建并配置为阻止公共访问: $BUCKET_NAME"
    echo $BUCKET_NAME > .bucket-name
fi
