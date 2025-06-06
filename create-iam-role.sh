#!/bin/bash
# create-iam-role.sh

# 获取区域参数
if [ -f .aws-region ]; then
    REGION=$(cat .aws-region)
else
    REGION="us-east-1"  # 默认区域
fi

echo "使用区域: $REGION"

# 创建 ECS 任务执行角色
ROLE_NAME="ecsTaskExecutionRole"

# 检查角色是否存在
ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME --query "Role.RoleName" --output text 2>/dev/null || echo "")

if [ "$ROLE_EXISTS" == "None" ] || [ -z "$ROLE_EXISTS" ]; then
    echo "创建 IAM 角色: $ROLE_NAME"
    
    # 创建信任策略文件
    cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    # 创建角色
    aws iam create-role \
      --role-name $ROLE_NAME \
      --assume-role-policy-document file://trust-policy.json \
      --region $REGION

    # 附加策略
    aws iam attach-role-policy \
      --role-name $ROLE_NAME \
      --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy \
      --region $REGION
    
    echo "IAM 角色已创建: $ROLE_NAME"
else
    echo "IAM 角色已存在: $ROLE_NAME"
fi
