#!/bin/bash
# create-cloudfront.sh

# 获取区域参数
if [ -n "$1" ]; then
    REGION="$1"
elif [ -f .aws-region ]; then
    REGION=$(cat .aws-region)
else
    REGION="us-east-1"  # 默认区域
fi

echo "使用区域: $REGION"

# 检查是否已存在 CloudFront 分发
if [ -f .distribution-id ]; then
    DISTRIBUTION_ID=$(cat .distribution-id)
    CLOUDFRONT_DOMAIN=$(cat .cloudfront-domain)
    echo "使用现有的 CloudFront 分发: $DISTRIBUTION_ID ($CLOUDFRONT_DOMAIN)"
else
    BUCKET_NAME=$(cat .bucket-name)
    BUCKET_REGIONAL_DOMAIN="$BUCKET_NAME.s3.$REGION.amazonaws.com"
    
    # 创建 Origin Access Control (OAC)
    echo "创建 CloudFront Origin Access Control..."
    
    # 生成唯一的 OAC 名称
    OAC_NAME="flagsmith-demo-oac-$(date +%s)"
    
    # 创建 OAC
    OAC_ID=$(aws cloudfront create-origin-access-control \
      --origin-access-control-config "{\"Name\":\"$OAC_NAME\",\"Description\":\"OAC for Flagsmith Demo\",\"SigningProtocol\":\"sigv4\",\"SigningBehavior\":\"always\",\"OriginAccessControlOriginType\":\"s3\"}" \
      --query "OriginAccessControl.Id" \
      --output text)
    
    echo "CloudFront Origin Access Control 已创建: $OAC_ID"
    echo $OAC_ID > .oac-id
    
    # 创建 CloudFront 分发
    echo "创建 CloudFront 分发: $BUCKET_REGIONAL_DOMAIN"
    
    # 创建 CloudFront 分发配置文件
    cat > cloudfront-config.json << EOF
{
    "CallerReference": "flagsmith-demo-$(date +%s)",
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3Origin",
                "DomainName": "$BUCKET_REGIONAL_DOMAIN",
                "S3OriginConfig": {
                    "OriginAccessIdentity": ""
                },
                "OriginAccessControlId": "$OAC_ID"
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3Origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["GET", "HEAD"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["GET", "HEAD"]
            }
        },
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            },
            "Headers": {
                "Quantity": 0
            },
            "QueryStringCacheKeys": {
                "Quantity": 0
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000,
        "Compress": true
    },
    "Comment": "Flagsmith Demo Distribution with OAC",
    "Enabled": true,
    "CustomErrorResponses": {
        "Quantity": 1,
        "Items": [
            {
                "ErrorCode": 403,
                "ResponsePagePath": "/index.html",
                "ResponseCode": "200",
                "ErrorCachingMinTTL": 10
            }
        ]
    }
}
EOF
    
    # 创建 CloudFront 分发
    DISTRIBUTION_ID=$(aws cloudfront create-distribution \
      --distribution-config file://cloudfront-config.json \
      --query "Distribution.Id" \
      --output text)
    
    echo "CloudFront 分发已创建: $DISTRIBUTION_ID"
    echo $DISTRIBUTION_ID > .distribution-id
    
    # 获取 CloudFront 域名
    CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution \
      --id $DISTRIBUTION_ID \
      --query "Distribution.DomainName" \
      --output text)
    
    echo "CloudFront 域名: $CLOUDFRONT_DOMAIN"
    echo $CLOUDFRONT_DOMAIN > .cloudfront-domain
    
    # 创建 S3 存储桶策略允许 CloudFront OAC 访问
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    
    cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipalReadOnly",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::$ACCOUNT_ID:distribution/$DISTRIBUTION_ID"
                }
            }
        }
    ]
}
EOF
    
    aws s3api put-bucket-policy \
      --bucket $BUCKET_NAME \
      --policy file://bucket-policy.json \
      --region $REGION
    
    echo "S3 存储桶策略已更新，允许 CloudFront OAC 访问"
    
    # 等待 CloudFront 分发部署完成
    echo "等待 CloudFront 分发部署完成..."
    aws cloudfront wait distribution-deployed --id $DISTRIBUTION_ID
    echo "CloudFront 分发已部署完成"
fi
