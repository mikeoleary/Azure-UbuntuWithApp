## Script parameters being asked for below match to parameters in the azuredeploy.json file, otherwise pointing to the ##
## azuredeploy.parameters.json file for values to use.  Some options below are mandatory, some (such as region) can    ##
## be supplied inline when running this script but if they aren't then the default will be used as specified below.    ##
## Example Command: .\Deploy_via_PS.ps1 -adminUsername azureuser -authenticationType password -adminPasswordOrKey <value> -dnsLabel <value> -instanceName f5vm01 -instanceType Standard_DS3_v2 -imageName AllTwoBootLocations -bigIpVersion 13.1.100000 -licenseKey1 <value> -numberOfAdditionalNics 1 -additionalNicLocation <value> -numberOfExternalIps 1 -vnetAddressPrefix 10.0 -ntpServer 0.pool.ntp.org -timeZone UTC -customImage OPTIONAL -allowUsageAnalytics Yes -resourceGroupName <value>

param(
  [string] $authenticationType = "",
  [string] $adminPasswordOrKey = "",
  [string] $virtualNetworkName = "",
  [string] $subnetName = "",
  [string] $privateIPAddress = "",
  [Parameter(mandatory=$true)] [string] $resourceGroupName,
  [Parameter(mandatory=$true)] [string] $region = "",
  [string] $templateFilePath = "azuredeploy.json",
  [string] $parametersFilePath = "azuredeploy.parameters.json"
)

# Connect to Azure, right now it is only interactive login
try {
    Write-Host "Checking if already logged in!"
    Get-AzureRmSubscription | Out-Null
    Write-Host "Already logged in, continuing..."
    }
    catch {
      Write-Host "Not logged in, please login..."
      Login-AzureRmAccount
    }

# Create Resource Group for ARM Deployment
New-AzureRmResourceGroup -Name $resourceGroupName -Location "$region"  -Verbose -Force 2> $null

$adminPasswordOrKeySecure = ConvertTo-SecureString -String $adminPasswordOrKey -AsPlainText -Force

# Create Arm Deployment
$deployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                                 -TemplateFile $templateFilePath `
                                                 -TemplateParameterFile $parametersFilePath `
                                                 -adminPasswordOrKey $adminPasswordOrKeySecure `
                                                 -virtualNetworkName $virtualNetworkName `
                                                 -subnetName $subnetName `
                                                 -privateIPAddress $privateIPAddress `
                                                 -Verbose `
                                                 -Force

# Print Output of Deployment to Console
$deployment