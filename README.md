# sampleRepo001

Azure 上の **仮想ネットワーク (vNet) 内に Windows Server VM を 1 台作成する** Bicep テンプレートです。

---

## 概要

このリポジトリには、Azure Resource Manager (ARM) の Infrastructure-as-Code ツールである **Bicep** を使用して、以下のリソースを一括デプロイするテンプレートが含まれています。

### 作成される Azure リソース

| リソース | 説明 |
|---|---|
| Virtual Network (vNet) | VM を配置する仮想ネットワーク |
| Subnet | vNet 内のサブネット |
| Network Security Group (NSG) | サブネットに関連付けるネットワーク セキュリティ グループ |
| Network Interface (NIC) | VM に接続するネットワーク インターフェイス |
| Public IP Address (オプション) | VM へのパブリック アクセス用 IP（`createPublicIp = false` で無効化可） |
| Virtual Machine (Windows) | Windows Server 2022 の仮想マシン |

---

## ファイル構成

```
.
├── main.bicep          # メイン Bicep テンプレート
├── main.bicepparam     # サンプル パラメーター ファイル
└── main.json           # ARM テンプレート（main.bicep のビルド成果物）
```

---

## 前提条件

- [Azure CLI](https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli) がインストール済みであること
- デプロイ先の Azure サブスクリプションおよびリソース グループが存在すること
- リソース グループへのデプロイ権限があること

---

## パラメーター

| パラメーター名 | 型 | 既定値 | 説明 |
|---|---|---|---|
| `location` | string | リソース グループのリージョン | リソースをデプロイするリージョン |
| `vmName` | string | `vm-sample` | VM の名前 |
| `vmSize` | string | `Standard_B2s` | VM のサイズ |
| `imagePublisher` | string | `MicrosoftWindowsServer` | OS イメージのパブリッシャー |
| `imageOffer` | string | `WindowsServer` | OS イメージのオファー |
| `imageSku` | string | `2022-datacenter-azure-edition` | OS イメージの SKU |
| `osDiskStorageAccountType` | string | `Premium_LRS` | OS ディスクのストレージ タイプ |
| `adminUsername` | string | `azureuser` | 管理者ユーザー名 |
| `adminPassword` | securestring | *(必須)* | 管理者パスワード（12 文字以上） |
| `vnetName` | string | `vnet-sample` | 仮想ネットワークの名前 |
| `vnetAddressPrefix` | string | `10.0.0.0/16` | 仮想ネットワークのアドレス空間 (CIDR) |
| `subnetName` | string | `snet-vm` | サブネットの名前 |
| `subnetAddressPrefix` | string | `10.0.1.0/24` | サブネットのアドレス プレフィックス (CIDR) |
| `createPublicIp` | bool | `true` | パブリック IP アドレスを作成するか |
| `tags` | object | `{}` | リソースに付与するタグ |

---

## デプロイ方法

### 1. Azure CLI でログイン

```bash
az login
```

### 2. パラメーター ファイルを編集

`main.bicepparam` を編集し、環境に合わせた値を設定します。  
管理者パスワード (`adminPassword`) はファイルに直接記載せず、デプロイ時に引数で渡すことを推奨します。

### 3. デプロイ実行

```bash
az deployment group create \
  --subscription <subscriptionId> \
  --resource-group <resourceGroupName> \
  --location japaneast \
  --template-file main.bicep \
  --parameters @main.bicepparam \
  --parameters adminPassword=<password>
```

> **注意:** `adminPassword` は 12 文字以上で、大文字・小文字・数字・記号をそれぞれ含む必要があります。

---

## 出力値

デプロイ完了後、以下の値が出力されます。

| 出力名 | 説明 |
|---|---|
| `vmId` | VM のリソース ID |
| `privateIpAddress` | VM のプライベート IP アドレス |
| `publicIpAddress` | VM のパブリック IP アドレス（`createPublicIp = true` の場合のみ） |
| `vnetId` | 仮想ネットワークのリソース ID |
