// ============================================================
// main.bicepparam
// main.bicep のサンプル パラメーター ファイル
//
// デプロイ例:
//   az deployment group create \
//     --subscription <subscriptionId> \
//     --resource-group <resourceGroupName> \
//     --location japaneast \
//     --template-file main.bicep \
//     --parameters @main.bicepparam
// ============================================================

using 'main.bicep'

// リージョン
param location = 'japaneast'

// VM 設定
param vmName = 'vm-sample'
param vmSize = 'Standard_B2s'

// OS イメージ (Windows Server 2022)
param imagePublisher = 'MicrosoftWindowsServer'
param imageOffer = 'WindowsServer'
param imageSku = '2022-datacenter-azure-edition'

// OS ディスク
param osDiskStorageAccountType = 'Premium_LRS'

// 管理者アカウント
param adminUsername = 'azureuser'
// adminPassword は機密情報のため、デプロイ時に --parameters adminPassword=<password> で指定するか
// Azure Key Vault 参照を使用してください。
// param adminPassword = ''

// ネットワーク設定
param vnetName = 'vnet-sample'
param vnetAddressPrefix = '10.0.0.0/16'
param subnetName = 'snet-vm'
param subnetAddressPrefix = '10.0.1.0/24'

// パブリック IP を作成しない場合は false に変更
param createPublicIp = true

// タグ
param tags = {
  environment: 'dev'
  owner: 'your-team'
}
