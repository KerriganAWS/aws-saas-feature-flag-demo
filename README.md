# AWS SaaS 特性標誌示範

這個專案展示了如何使用 Flagsmith 開源特性標誌服務在 AWS 上部署一個完整的特性標誌管理解決方案。

## 架構概覽

此示範使用以下 AWS 服務：

- **Amazon S3** - 託管前端靜態檔案
- **Amazon CloudFront** - 提供全球內容分發網路
- **Flagsmith SaaS** - 提供特性標誌管理服務

## 示範功能

本示範展示了特性標誌的四個主要使用案例：

1. **漸進式發布** - 逐步向一小部分使用者推出新功能
2. **A/B 測試** - 對不同使用者群展示不同版本的功能來測試效果
3. **即時功能控制** - 不需重新部署即可開啟或關閉功能
4. **VIP 專屬功能** - 只對特定使用者群顯示的功能

## 部署說明

### 前提條件

- AWS CLI 已安裝並設定
- 具有適當權限的 AWS 帳戶
- bash 或相容的 shell 環境

### 部署步驟

1. 複製此儲存庫：
   ```bash
   git clone https://github.com/KerriganAWS/aws-saas-feature-flag-demo.git
   cd aws-saas-feature-flag-demo
   ```

2. 執行設定腳本：
   ```bash
   chmod +x *.sh
   ./setup.sh --region ap-northeast-1  # 可以指定任何有效的 AWS 區域
   ```

3. 部署完成後，您將獲得：
   - CloudFront 分發的 URL（用於存取前端）

### 更新部署

如果您需要更新部署，只需再次執行相同的指令：

```bash
./setup.sh --region ap-northeast-1  # 使用與初始部署相同的區域
```

腳本會偵測現有資源並更新它們，而不是重新建立。

### 設定 Flagsmith

1. 註冊並登入 [Flagsmith](https://app.flagsmith.com/)
2. 建立一個新的專案和環境
3. 建立以下特性標誌：
   - `progressive_release` - 漸進式發布範例（布林值）
   - `button_color` - A/B 測試範例（值：primary、success、danger 等）
   - `maintenance_mode` - 即時功能控制範例（布林值）
   - `vip_feature` - VIP 專屬功能範例（布林值）
4. 設定特性標誌的規則（如百分比發布、使用者分群等）
5. 取得環境 ID 並更新前端應用程式中的設定

## 檔案結構

- `setup.sh` - 主設定腳本
- `deploy.sh` - 部署腳本
- `create-iam-role.sh` - 建立 IAM 角色
- `create-frontend-resources.sh` - 建立 S3 儲存貯體
- `create-cloudfront.sh` - 建立 CloudFront 分發
- `create-frontend-files.sh` - 準備前端檔案
- `frontend/` - 前端示範應用程式檔案
- `cleanup.sh` - 清理資源腳本

## 清理資源

要刪除所有建立的資源，請執行：

```bash
./cleanup.sh
```

## 安全性

請注意，此示範專案設定為允許公開存取以便於展示。在正式環境中，您應該實施適當的安全措施，如：

- 使用 HTTPS
- 實施適當的身份驗證和授權
- 限制網路存取
- 使用 AWS Secrets Manager 儲存敏感資訊

## 授權條款

此範例程式碼遵循 MIT-0 授權條款。詳見 LICENSE 檔案。
