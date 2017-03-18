# *CAD Customer Loyalty Business Scenario Hackathon*

# What is it?

This repository will provision an environment that may be used as a Hackathon to build an end to end scenario that does the following:

*	Query a Contact List API for a customer
*	Query our legacy on-prem Ticket system to get the customer’s last feedback
*	Perform sentiment analysis on this feedback
*	Generate a digital discount coupon if they were dissatisfied
*	Mail them the coupon

# What does it showcase?

This solution brings together Infrastructure as a Service (IaaS), Platform as a Service (PaaS), Software as a Service (SaaS) and Serverless components on Microsoft Azure to build a realistic end to end scenario common in retail. Furthermore, the democratization of AI is tied in nicely by incorporating Cognitive Services to perform text analysis and determine the sentiment of a customer’s feedback.

# The end to end scenario

This solution will query a customer datastore, then get the last support case associated with a customer from a different datastore, check the sentiment/satisfaction of the customer's last feedback and generate a digital discount coupon for them if their sentiment is determined to be dissatisfied. The coupon will then be emailed to the customer to redeem. 

# The solution aims to show the following:

*	How legacy lift and shift applications on IaaS can be incorporated into modern solutions to quickly derive value from higher value services in the cloud.
*	How existing investments can be modernized without having to rebuild everything to drive customer value
*	The ease with which On-premise, public and private components may be brought together to build workloads that bring business value
*	The meshing of IaaS, PaaS, SaaS, Serverless and AI with tools that are accessible to non-developers
*	OSS workloads running on Azure

# Technology used

The following technology components are used in this solution:

*	Swagger enabled Node.js APIs running on Azure App Services (PaaS)
*	Ubuntu with a custom extension template to rapidly provision and deploy a custom image with a running legacy mysql solution (IaaS) [Thanks Justin Davies for helping here](https://github.com/juda-ms)
*	Azure networking to isolate legacy workloads (IaaS)
*	API Management to govern APIs and to bridge publicly accessible APIs with isolated APIs (SaaS) (IaaS)
*	Azure functions to run dynamic ‘pay-as-you-go’ compute (Serverless) [Thanks Christof Claasens and Katrien de Graeve for the generate coupon function](https://github.com/xstof/Quiz) 
*	Azure logic apps to provide serverless integration that is accessible to non-developers (Serveless)
*	Azure Resource Manager templates to automate the provisioning and inflation of a full environment

# Solution flow

![alt text](https://github.com/shanepeckham/MiniCADHackathon/blob/master/Typology.jpg "Solution Flow")

# The Hackathon component

This solution will install and configure all of the components required to build the end to end Loyalty scenario. The Hackathon attendees just need to wire everything together in a Logic App. 

# Preparing for the solution

For this Hackathon you will require:
* A cognitive services trial account key, get it here - https://www.microsoft.com/cognitive-services/en-us/sign-up
* A Gmail account for sending emails, get it here - https://accounts.google.com/SignUp?service=mail&continue=http%3A%2F%2Fmail.google.com%2Fmail%2Fe-11-14a952576b5f2ffe90ec0dd9823744e0-46a962fbb7947b68059374ddde7f29b5490a6b4d
* Install Postman, get it here - https://www.getpostman.com
* If using Windows 10 get Bash for Windows - https://msdn.microsoft.com/en-us/commandline/wsl/install_guide or putty if on an older version - http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

# How to install the solution

## 1. Provisioning the components: Select Deploy to Azure to deploy to your Azure instance that you are currently logged in to.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fshanepeckham%2FCADHackathon_Loyalty%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fshanepeckham%2FCADHackathon_Loyaltys%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The only parameter you need to change is the Deployment Name - give it any name of 12 characters or less as it will be used to generate a hash to ensure your site names are unique, see the image below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/DeploymentName.jpg)

This will take roughly 30 minutes as this will provision:

* Two VNETs
* An Ubuntu VM and place in inside the VNET isolated with NSGs
* An API Management instance (Developer Tier) and place it inside a subnet within the VNET
* An App Service API app (Contact List) and deploy a node.js Swagger enabled API to it
* An App Service serverless function with dynamic scaling and pricing
* Storage accounts to house the VM VHD, the Function logging and the App Service API logging

## 2. Checking the Contact List API App: Once deployment is complete, navigate to your App Service API App, its default name will be CADAPIMasterSite[hash] and click on the URI in the overview blade, see below:

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/App_URI.png)

This will navigate you to a URL that will display the following message if it was provisioned correctly:
```
Cannot GET / 
```
Now type ``` /docs ``` after the azurewebsites.net part of the url and you should see the Swagger editor open with a test harness to test the API:

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/swaggerharness.png)

You should now be able to test a few methods of the API to check if how it works. It will query 3 contacts and methods exist to query all, query by Id, query associated Case Number by Id and query contact Email by Id.

Now copy the URL without the ``` /docs ``` component and paste is somewhere for retrieval later on.

### Change the email addresses to in the contact API to your email

* Navigate back to your API App in the Azure portal - e.g. http://cadapimastersite[hash].azurewebsites.net
* Select the Advancted Tools blade and then click Go. This will open the Kudu console where we can be naughty and go and edit the source files 
* In the top menu select Debug Console --> CMD
* In the top tree folder structure click Site --> WWWRoot --> lib -- and click the pencil next to the contacts.json file. 
* Change the email for the contact you want to change
* Click Save
* Restart your API App. This can be done from the Restart button on the overview blade

## 3. Now we will import the Contact List API into the API Management solution

Navigate to API Management component provisioned within Azure, its name will be generated by default with the following format cadapim[hash].

Click on the overview blade and select 'Publisher Portal' (note we will use the old portal while the new portal is still in preview), see below:

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/apimpublisherportal.png)

This will navigate you to the Publisher portal, select Import API, see below:

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/importAPI.png)

Now enter the following values:

* Select "From Url"
* Paste your API URL from step 2 and add ``` /swagger ``` on the end e.g. http://cadapimastersite[hash].azurewebsites.net/swagger
* Select "Swagger" as the specification format
* Select New API
* Type "Contacts" into the Web API URL Suffix field
* Click Products and select "Unlimited"
* Click Save

See below:

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/importapidetails.png)

You will now have imported an API that will now be accessible from the API Gateway. You can test it by clicking on Developer Portal, see below:

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/developerportal.png)

Click APIs --> Contact List API --> Try It

This will take you to the test harness of API Management. Click the eyeball and copy the value in the field Ocp-Apim-Subscription-Key, this is your APIMKey which we will use extensively, see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/APIMKey.jpg)

You can test the API now and it should return values with a status of 200 Ok.

We have now set up the first API in our process.

## 4. Install the legacy Ticket API on the VM

We could deploy this script as a custom script extension on the VM but that will complicate troubleshooting in a lab scenario so we will manually connect to the machine and run the build script, it is a single install script that will set up everything required.

Navigate to your VM, the default name will be CADLegacyAPI[hash] and navigate to the Overview blade and copy the value in the field Public IP Address/DNS label, see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/VMIP.jpg)

We will now ssh onto the machine using Bash for Windows on Windows 10, or putty or just plain old terminal on a mac or Linux.

* Type ssh MiniCADAdmin@[pasted ip address - without value '/none' on the end) e.g. ssh MiniCADAdmin@12.34.56.78 and press enter - see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/ssh2.jpg)

* Select yes to the message "Are you sure you want to continue connecting"
* Type in password MiniCADAdmin123 - note this is hardcoded in the deploy
* Paste the following in the command line: ``` git clone https://github.com/shanepeckham/CADHackathon_Loyalty.git ```
* Now type ``` cd CADHackathon_Loyalty ```
* Now type ``` bash installVM.sh ```
* Upon completion you will see a screen similar to that below, with the final status 'Starting Legacy API'

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/StartingAPI.jpg)

Your Legacy Ticket API should now be listening on port 8000 but this will not be accessible from the outside world. Note, if you restart your VM or want to restart the legacy api, simply navigate to the /LegacyAPI/CADContacts folder and run node server.js. 
e.g.

```cd LegacyAPI 
cd CADContacts
node server.js
```
 
## 5. Now we will import the Case Contact List API (Legacy Ticket API) into API Management.

Navigate to API Management component provisioned within Azure, its name will be generated by default with the following format cadapim[hash].

Click on the overview blade and select 'Publisher Portal' (note we will use the old portal while the new portal is still in preview), see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/APIMPublisherPortal.jpg)

This will navigate you to the Publisher portal, select Import API, see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/ImportAPI.jpg)

Now enter the following values:

* Select "From Url"
* Paste http://10.1.1.4:8000/swagger into this field. Note this is your internal VNET address for your VM
* Select "Swagger" as the specification format
* Select New API
* Type "LegacyAPI" into the Web API URL Suffix field
* Click Products and select "Unlimited"
* Click Save

See below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/LegacyAPIImport.jpg)

You will now have imported an API that will now be accessible from the API Gateway. You can test it by clicking on Developer Portal, see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/DevPortalLegacy.jpg)

Click APIs --> Contact Case List API --> Try It

This will take you to the test harness of API Management. Click the eyeball and copy the value in the field Ocp-Apim-Subscription-Key, this is your APIMKey which we will use extensively, see below:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/APIMKey.jpg)

You can test the API now and it should return values with a status of 200 Ok.

We have now set up the legacy Ticket API in our process.

## 6. Import Function Storage hooks

Click on the Deploy button below.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fshanepeckham%2FCADHackathon_Loyalty%2Fmaster%2Fazuredeployfunctionsettings.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

NB - Make sure you use the same Deployment Name as you did in Step 1.

You can test the function in the test harness within the function app itself, add this to the Request body:
```
{ "name": "hello" }
```
You should see the output look something like this:
```
{"couponUrl":"https://cadfuncstorrvhyzok7zv4gw.blob.core.windows.net/coupons/%5Bobject%20Object%5D.jpg?st=2017-03-14T20%3A27%3A59Z&se=2017-03-14T21%3A27%3A59Z&sp=r&sv=2015-12-11&sr=b&sig=6UUHFHY08JihUU8vT%2Fus%2Fot9Pl%2BZud6jaakMNTuCFZc%3D"} Status 200 Ok
```
Note, if you get an error upon first invocation, run it again and it should work. You are now ready to build the logic app.

# The Logic App solution

We want to get the customer's details, find their last associated case and then chek the feedback against it.

### The data model

See the diagram below for the simplistic data model to help you query the right data.

![alt text](https://github.com/shanepeckham/CADLab_Loyalty/blob/master/Images/DemoDataModel.jpg)

Create a HTTP Request Step, click save - you will receive an endpoint upon save. 

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/HTTP%20Request.jpg)

You can now invoke your logic app with Postman - add the URL and select POST. Ensure you have set the Header "Content-Type" with value "application/json". Select body, select "raw" and enter the follow value for your body content:
```
{
  "APIMKey": "[Your APIM Key goes here]",
  "id": 1
}
```
![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/PostManHeaders.jpg)
![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/PostManBody.jpg)

Now add a step to include an API Management API - select your API "Contact List API". You will want to select the method GET for contacts/{id}

You will need to navigate to the code view to be able to select the json fields that will be posted as part of the body. Your code view should look like this:
```
"Query_Contacts_by_Id": {
                "inputs": {
                    "api": {
                        "id": "/subscriptions/[subscription id]/resourceGroups/MiniCAD/providers/Microsoft.ApiManagement/service/minicad123api/apis/[api id]"
                    },
                    "method": "get",
                    "pathTemplate": {
                        "parameters": {
                            "id": "@{encodeURIComponent(int(triggerBody()['id']))}"
                        },
                        "template": "/Contacts/contacts/{id}"
                    },
                    "subscriptionKey": "@{encodeURIComponent(triggerBody()['APIMKey'])}"
                },
                "runAfter": {},
                "type": "ApiManagement"
            }

```
Now add a For Each loop as we want to iterate through the resultset, so select the Body as the output from your previous request.

[!alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/ForEach.jpg)

Now you want to add a step to query the Legacy Ticket API which is inside the isolated network, add an API Management API step and once again query the Id, which in this case is the casenum output from the previous step and add the API Management subscription key.

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/QueryCasesFeedback.jpg)

Here is what your code view should look like:
```
"Query_Cases_Feedback": {
                        "inputs": {
                            "api": {
                                "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/[Your Resource Group]/providers/Microsoft.ApiManagement/service/minicad123api/apis/58af3fded9e0430e784c6b9d"
                            },
                            "method": "get",
                            "pathTemplate": {
                                "parameters": {
                                    "id": "@{encodeURIComponent(item()?['caseNum'])}"
                                },
                                "template": "/LegacyAPI/contacts/{id}"
                            },
                            "subscriptionKey": "@{encodeURIComponent(triggerBody()['APIMKey'])}"
                        },
                        "runAfter": {},
                        "type": "ApiManagement"
                    },
```

Now we want to add our Cognitive Services 'Detect Sentiment' step so that we can analyse the sentiment of the Ticket Feedback, your step should look like this:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/DetectSentiment.jpg)

Your code view should look like this:
```
"Detect_Sentiment": {
                        "inputs": {
                            "body": {
                                "text": "@body('Query_Cases_Feedback')['last_feedback']"
                            },
                            "host": {
                                "api": {
                                    "runtimeUrl": "https://logic-apis-northeurope.azure-apim.net/apim/[YourCognitiveServicesConnectionName]"
                                },
                                "connection": {
                                    "name": "@parameters('$connections')[YourCognitiveServicesConnectionName]['connectionId']"
                                }
                            },
                            "method": "post",
                            "path": "/sentiment"
                        },
                        "runAfter": {
                            "Query_Cases_Feedback": [
                                "Succeeded"
                            ]
                        },
                        "type": "ApiConnection"
                    },
```

Now we want to add a condition to check the sentiment, if the probability outcome is less than 0.5, then it negative sentiment and therefore qualifies for our discount coupon.

Your condition should look like this:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/Condition.jpg)

With the following in code view:
```
"expression": "@less(body('Detect_Sentiment')?['score'], 0.5)",
                        "runAfter": {
                            "Detect_Sentiment": [
                                "Succeeded"
                            ]
                        },
                        "type": "If"

```

Now you can call the GenerateCoupon function if the condition is met, pass in the name of the user that you want to generate the digital coupon for:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/IfCondition.jpg)

With the following in the code view:
```
"GenerateCoupon": {
                                "inputs": {
                                    "body": {
                                        "name": "@item()?['name']"
                                    },
                                    "function": {
                                        "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/[Your Resource Group]/providers/Microsoft.Web/sites/MiniCADFunctionApp4pb56ec3fmsgg/functions/GenerateCoupon"
                                    },
                                    "method": "POST"
                                },
                                "runAfter": {},
                                "type": "Function"
                            }
```
Now we want to send an email to every receipient to inform them that they can download a digital coupon which we have generated for them. Your email step should look like this:

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/Email.jpg)

With the following code view:
```
"Send_email": {
                        "inputs": {
                            "body": {
                                "Body": "Please get your coupon here: @{body('GenerateCoupon')}",
                                "Subject": "Your Coupon has been generated",
                                "To": "@{item()?['email']}"
                            },
                            "host": {
                                "api": {
                                    "runtimeUrl": "https://logic-apis-northeurope.azure-apim.net/apim/gmail"
                                },
                                "connection": {
                                    "name": "@parameters('$connections')['gmail']['connectionId']"
                                }
                            },
                            "method": "post",
                            "path": "/Mail"
                        },
                        "runAfter": {
                            "Condition": [
                                "Succeeded"
                            ]
                        },
                        "type": "ApiConnection"
                    }
```

The full code solution view looks like this:
```
{
    "$connections": {
        "value": {
            "cognitiveservicestextanalytics": {
                "connectionId": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/MiniCAD/providers/Microsoft.Web/connections/cognitiveservicestextanalytics",
                "connectionName": "cognitiveservicestextanalytics",
                "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/providers/Microsoft.Web/locations/northeurope/managedApis/cognitiveservicestextanalytics"
            },
            "gmail": {
                "connectionId": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/MiniCAD/providers/Microsoft.Web/connections/gmail",
                "connectionName": "gmail",
                "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/providers/Microsoft.Web/locations/northeurope/managedApis/gmail"
            }
        }
    },
    "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {
            "For_each": {
                "actions": {
                    "Condition": {
                        "actions": {
                            "GenerateCoupon": {
                                "inputs": {
                                    "body": {
                                        "name": "@item()?['name']"
                                    },
                                    "function": {
                                        "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/MiniCADFunction/providers/Microsoft.Web/sites/MiniCADFunctionApp4pb56ec3fmsgg/functions/GenerateCoupon"
                                    },
                                    "method": "POST"
                                },
                                "runAfter": {},
                                "type": "Function"
                            }
                        },
                        "expression": "@less(body('Detect_Sentiment')?['score'], 0.5)",
                        "runAfter": {
                            "Detect_Sentiment": [
                                "Succeeded"
                            ]
                        },
                        "type": "If"
                    },
                    "Detect_Sentiment": {
                        "inputs": {
                            "body": {
                                "text": "@body('Query_Cases_Feedback')['last_feedback']"
                            },
                            "host": {
                                "api": {
                                    "runtimeUrl": "https://logic-apis-northeurope.azure-apim.net/apim/cognitiveservicestextanalytics"
                                },
                                "connection": {
                                    "name": "@parameters('$connections')['cognitiveservicestextanalytics']['connectionId']"
                                }
                            },
                            "method": "post",
                            "path": "/sentiment"
                        },
                        "runAfter": {
                            "Query_Cases_Feedback": [
                                "Succeeded"
                            ]
                        },
                        "type": "ApiConnection"
                    },
                    "Query_Cases_Feedback": {
                        "inputs": {
                            "api": {
                                "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/MiniCAD/providers/Microsoft.ApiManagement/service/minicad123api/apis/58af3fded9e0430e784c6b9d"
                            },
                            "method": "get",
                            "pathTemplate": {
                                "parameters": {
                                    "id": "@{encodeURIComponent(item()?['caseNum'])}"
                                },
                                "template": "/LegacyAPI/contacts/{id}"
                            },
                            "subscriptionKey": "@{encodeURIComponent(triggerBody()['APIMKey'])}"
                        },
                        "runAfter": {},
                        "type": "ApiManagement"
                    },
                    "Send_email": {
                        "inputs": {
                            "body": {
                                "Body": "Please get your coupon here: @{body('GenerateCoupon')}",
                                "Subject": "Your Coupon has been generated",
                                "To": "@{item()?['email']}"
                            },
                            "host": {
                                "api": {
                                    "runtimeUrl": "https://logic-apis-northeurope.azure-apim.net/apim/gmail"
                                },
                                "connection": {
                                    "name": "@parameters('$connections')['gmail']['connectionId']"
                                }
                            },
                            "method": "post",
                            "path": "/Mail"
                        },
                        "runAfter": {
                            "Condition": [
                                "Succeeded"
                            ]
                        },
                        "type": "ApiConnection"
                    }
                },
                "foreach": "@body('Query_Contacts_by_Id')",
                "runAfter": {
                    "Query_Contacts_by_Id": [
                        "Succeeded"
                    ]
                },
                "type": "Foreach"
            },
            "Query_Contacts_by_Id": {
                "inputs": {
                    "api": {
                        "id": "/subscriptions/de019774-dddc-40a9-9515-51f9df268c95/resourceGroups/MiniCAD/providers/Microsoft.ApiManagement/service/minicad123api/apis/58af405bd9e0430e784c6b9f"
                    },
                    "method": "get",
                    "pathTemplate": {
                        "parameters": {
                            "id": "@{encodeURIComponent(int(triggerBody()['id']))}"
                        },
                        "template": "/Contacts/contacts/{id}"
                    },
                    "subscriptionKey": "@{encodeURIComponent(triggerBody()['APIMKey'])}"
                },
                "runAfter": {},
                "type": "ApiManagement"
            }
        },
        "contentVersion": "1.0.0.0",
        "outputs": {},
        "parameters": {
            "$connections": {
                "defaultValue": {},
                "type": "Object"
            }
        },
        "triggers": {
            "manual": {
                "inputs": {
                    "schema": {}
                },
                "kind": "Http",
                "type": "Request"
            }
        }
    }
}

```
# Troubleshooting

If you get and 'Internal Server Error' 500 on the Contact Case List (Legacy Ticket API) this could be because the node API has stopped. ssh into the VM and navigate to the /LegacyAPI/CADContacts folder and run 'node server.js'. 
e.g.

```cd LegacyAPI 
cd CADContacts
node server.js
```
