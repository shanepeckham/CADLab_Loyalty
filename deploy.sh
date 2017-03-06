#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

usage() { echo "Usage: $0 -i <subscriptionId> -g <resourceGroupName> -n <deploymentName> -l <resourceGroupLocation>" 1>&2; exit 1; }

declare subscriptionId=""
declare resourceGroupName=""
declare deploymentName=""
declare resourceGroupLocation=""

# Initialize parameters specified from command line
while getopts ":i:g:d:n:l:" arg; do
	case "${arg}" in
		i)
			subscriptionId=${OPTARG}
			;;
		g)
			resourceGroupName=${OPTARG}
			;;
		d)
			resourceGroupNameDynamic=${OPTARG}
			;;
		n)
			deploymentName=${OPTARG}
			;;
		l)
			resourceGroupLocation=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$subscriptionId" ]]; then
	echo "Subscription Id:"
	read subscriptionId
	[[ "${subscriptionId:?}" ]]
fi

if [[ -z "$resourceGroupName" ]]; then
	echo "ResourceGroupName:"
	read resourceGroupName
	[[ "${resourceGroupName:?}" ]]
fi

if [[ -z "$deploymentName" ]]; then
	echo "DeploymentName:"
	read deploymentName
fi

if [[ -z "$resourceGroupLocation" ]]; then
	echo "Enter a location below to create a new resource group else skip this"
	echo "ResourceGroupLocation:"
	read resourceGroupLocation
fi

#templateFile Path - template file to be used
#templateFilePath="template.json"
templateAPI="templateAPI.json"
templateAPIM="templateAPIM.json"
templateAPISettings="templateAPISettings.json"
templateFunction="templateFunction.json"
templateFunctionSettings="templateFunctionSettings.json"
templateLogic="templateLogic.json"
templateVM="templateVM.json"

if [ ! -f "$templateFilePath" ]; then
	echo "$templateFilePath not found"
	exit 1
fi

#parameter file path
parametersFilePath="parameters.json"

if [ ! -f "$parametersFilePath" ]; then
	echo "$parametersFilePath not found"
	exit 1
fi

if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ] || [ -z "$deploymentName" ]; then
	echo "Either one of subscriptionId, resourceGroupName, deploymentName is empty"
	usage
fi

#login to azure using your credentials
az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

#set the default subscription id
az account set --name $subscriptionId

set +e

#Check for existing RG
az group show $resourceGroupName 1> /dev/null

if [ $? != 0 ]; then
	echo "Resource group with name" $resourceGroupName "could not be found. Creating new resource group.."
	set -e
	(
		set -x
		az resource group create --name $resourceGroupName --location $resourceGroupLocation 1> /dev/null
	)
	else
	echo "Using existing resource group..."
fi

#Start deployment of VM and network
echo "Starting deployment of VM and network..."
(
	set -x
	az resource group deployment create --name $deploymentName --resource-group $resourceGroupName --template-file $templateVM --parameters $parametersFilePath
)

echo "Starting deployment of custom extension script for legacy environment"
	az vm extension set myResourceGroup myVM CustomScript Microsoft.Azure.Extensions 2.0 \
  		--auto-upgrade-minor-version \
  		--public-config '{"fileUris": ["https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/install.sh"],"commandToExecute": "./install.sh"}'



if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi

#Start deployment of API Management
echo "Starting deployment of API Management..."
(
	set -x
	az resource group deployment create --name $deploymentName --resource-group $resourceGroupName --template-file $templateAPIM --parameters $parametersFilePath
)

if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi

#Start deployment of App Services
echo "Starting deployment of App Services..."
(
	set -x
	az resource group deployment create --name $deploymentName --resource-group $resourceGroupName --template-file $templateAPI --parameters $parametersFilePath
)

if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi

#Start deployment of Azure Function
echo "Starting deployment of Azure Function..."

#Check for existing RG - a new one if required for Dynamic pricing
az group show $resourceGroupName 1> /dev/null

if [ $? != 0 ]; then
	echo "Resource group with name" $resourceGroupNameDynamic "could not be found. Creating new Dynamic resource group.."
	set -e
	(
		set -x
		az resource group create --name $resourceGroupNameDynamic --location $resourceGroupLocation 1> /dev/null
	)
	else
	echo "Using existing Dynamic resource group..."
fi

(
	set -x
	az resource group deployment create --name $deploymentName --resource-group $resourceGroupNameDynamic --template-file $templateFunction --parameters $parametersFilePath
)

#We also need a separate invocation to load the Function App settings
(
	set -x
	az resource group deployment create --name $deploymentName --resource-group $resourceGroupNameDynamic --template-file $templateFunctionSettings --parameters $parametersFilePath
)

if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi