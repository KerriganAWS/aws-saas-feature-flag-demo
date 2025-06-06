#!/bin/bash
# create-frontend-files.sh

# 如果存在 .cloudfront-domain 文件，则读取 CloudFront 域名
if [ -f .cloudfront-domain ]; then
    CLOUDFRONT_DOMAIN=$(cat .cloudfront-domain)
    echo "Using CloudFront domain: $CLOUDFRONT_DOMAIN"
fi

# 更新 app.js 中的 Flagsmith 环境 ID
# 注意：您需要将 YOUR_FLAGSMITH_ENVIRONMENT_ID 替换为您的 Flagsmith SaaS 环境 ID
sed -i '' "s|environmentID: \"YOUR_ENVIRONMENT_ID\"|environmentID: \"YOUR_FLAGSMITH_ENVIRONMENT_ID\"|g" frontend/app.js

# 更新 app.js 中的 API 端点为 Flagsmith SaaS API
sed -i '' "s|api: \"http://YOUR_ECS_ALB_ENDPOINT/api/v1\"|api: \"https://edge.api.flagsmith.com/api/v1\"|g" frontend/app.js

echo "Frontend files are ready in the ./frontend directory"
