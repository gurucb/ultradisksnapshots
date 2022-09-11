$subscriptionId = "9b585214-4a84-4c07-b1ed-10dcb3f5da32" 
$resourceGroup = "testultrapprg"
# $location = "eastus"
$location = "eastus2euap"
$diskSizeInGB = 1024
$diskIOPSReadWrite = 10000
$diskMbpsReadWrite = 1200
$logicalSectorSize = 4096
$virtualMachineName = "linuxGenIOVM5"
$virtualMachineSize = "Standard_D16s_v3"
$adminPassword = ConvertTo-SecureString "Password@1234" -AsPlainText -Force
$adminUsername = "epicadmin"

Set-AzContext -Subscription $subscriptionId

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup `
-TemplateFile "vmtemplate.json" `
-virtualMachineName $virtualMachineName `
-virtualMachineSize $virtualMachineSize `
-adminUsername $adminUsername `
-adminPassword $adminPassword `
-location $location `
-dataDiskSizeInGB $diskSizeInGB `
-diskIOPSReadWrite $diskIOPSReadWrite `
-diskMbpsReadWrite $diskMbpsReadWrite `
-logicalSectorSize $logicalSectorSize 