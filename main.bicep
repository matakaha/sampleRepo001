// ============================================================
// main.bicep
// vNet 内に VM を 1 台作成する Bicep テンプレート
//
// デプロイ例:
//   az deployment group create \
//     --subscription <subscriptionId> \
//     --resource-group <resourceGroupName> \
//     --location japaneast \
//     --template-file main.bicep \
//     --parameters @main.bicepparam
// ============================================================

// ---- デプロイ先スコープ ----
targetScope = 'resourceGroup'

// ---- パラメーター ----

@description('リソースをデプロイするリージョン')
param location string = resourceGroup().location

@description('VM の名前')
param vmName string = 'vm-sample'

@description('VM のサイズ (例: Standard_B2s, Standard_D2s_v3)')
param vmSize string = 'Standard_B2s'

@description('OS イメージのパブリッシャー')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('OS イメージのオファー')
param imageOffer string = 'WindowsServer'

@description('OS イメージの SKU')
param imageSku string = '2022-datacenter-azure-edition'

@description('OS ディスクのストレージ アカウント タイプ')
@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
])
param osDiskStorageAccountType string = 'Premium_LRS'

@description('管理者ユーザー名')
param adminUsername string = 'azureuser'

@description('管理者パスワード (12 文字以上、大小英字・数字・記号を含む)')
@secure()
param adminPassword string

@description('仮想ネットワークの名前')
param vnetName string = 'vnet-sample'

@description('仮想ネットワークのアドレス空間 (CIDR)')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('サブネットの名前')
param subnetName string = 'snet-vm'

@description('サブネットのアドレス プレフィックス (CIDR)')
param subnetAddressPrefix string = '10.0.1.0/24'

@description('パブリック IP アドレスを作成するか (false にすると VM は vNet 内のみ)')
param createPublicIp bool = true

@description('リソースに付与するタグ')
param tags object = {}

// ---- 変数 ----

var nicName = 'nic-${vmName}'
var publicIpName = 'pip-${vmName}'
var osDiskName = 'osdisk-${vmName}'
var nsgName = 'nsg-${subnetName}'

// ---- ネットワーク セキュリティ グループ ----

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// ---- 仮想ネットワーク ----

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// ---- パブリック IP アドレス (オプション) ----

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (createPublicIp) {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// ---- ネットワーク インターフェイス ----

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
          publicIPAddress: createPublicIp ? {
            id: publicIp.id
          } : null
        }
      }
    ]
  }
}

// ---- 仮想マシン ----

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskStorageAccountType
        }
        deleteOption: 'Delete'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// ---- 出力 ----

@description('VM のリソース ID')
output vmId string = vm.id

@description('VM のプライベート IP アドレス')
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress

@description('VM のパブリック IP アドレス (createPublicIp = true の場合のみ)')
output publicIpAddress string = createPublicIp ? publicIp!.properties.ipAddress : ''

@description('仮想ネットワークのリソース ID')
output vnetId string = vnet.id
