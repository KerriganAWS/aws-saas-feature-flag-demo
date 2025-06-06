#!/bin/bash
# setup.sh

# 默认区域
DEFAULT_REGION="us-east-1"

# 帮助信息
function show_help {
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  -r, --region REGION    指定 AWS 区域 (默认: $DEFAULT_REGION)"
    echo "  -h, --help             显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --region ap-northeast-1"
}

# 解析命令行参数
REGION=$DEFAULT_REGION

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

echo "开始设置 Flagsmith 演示环境..."
echo "使用区域: $REGION"

# 保存区域到配置文件
echo $REGION > .aws-region

# 1. 创建 IAM 角色
bash create-iam-role.sh

# 2. 创建前端文件
bash create-frontend-files.sh

# 3. 执行部署
bash deploy.sh

echo "设置完成!"
