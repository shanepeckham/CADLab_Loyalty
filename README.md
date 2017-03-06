# What is it?

This repository will provision an environment that may be used as a Hackathon to build an end to end scenario that does the following:

*	Query a CRM API for a customer
*	Query our legacy Ticket system to get the customer’s last feedback
*	Perform sentiment analysis on this feedback
*	Generate a digital discount coupon if they were dissatisfied
*	Mail them the coupon

# What does it showcase?

This solution brings together Infrastructure as a Service (IaaS), Platform as a Service (PaaS), Software as a Service (saaS) and Serverless components on Microsoft Azure to build a realistic end to end scenario common in retail. Furthermore, the democratization of AI is tied in nicely by incorporating Cognitive Services to perform text analysis and determine the sentiment of a customer’s feedback.

The solution aims to show the following:

*	How legacy lift and shift applications on IaaS can be incorporated into modern solutions to quickly derive value from higher value services in the cloud.
*	How existing investments can be modernized without having to rebuild everything to drive customer value
*	The ease with which On-premise, public and private components may be brought together to build workloads that bring business value
*	The meshing of IaaS, PaaS, SaaS, Serverless and AI with tools that are accessible to non-developers
*	OSS workloads running on Azure

# Technology used

The following technology components are used in this solution:

*	Swagger enabled Node.js APIs running on Azure App Services (PaaS)
*	Ubuntu with a custom extension template to rapidly provision and deploy a custom image with an running solution (IaaS)
*	Azure networking to isolate legacy workloads (IaaS)
*	API Management to govern APIs and to bridge publicly accessible APIs with isolated APIs (SaaS) (IaaS)
*	Azure functions to run dynamic ‘pay-as-you-go’ compute (Serverless) [Thanks Christof Claasens](https://github.com/xstof/Quiz) 
*	Azure logic apps to provide serverless integration that is accessible to non-developers (Serveless)
*	Azure Resource Manager templates to automate the provisioning and inflation of a full environment
*	The Azure CLI 2.0

# Solution flow

![alt text](https://github.com/shanepeckham/MiniCADHackathon/blob/master/Typology.jpg)

# The Hackathon component

This solution will install and configure all of the components required to build the end to end Loyalty scenario. The Hackathon attendees just need to wire everything together in a Logic App. 

# Preparing environment

For this Hackathon you will require:
* A cognitive services trial account key, get it here - https://www.microsoft.com/cognitive-services/en-us/sign-up
* A Gmail account for sending emails, get it here - https://accounts.google.com/SignUp?service=mail&continue=http%3A%2F%2Fmail.google.com%2Fmail%2Fe-11-14a952576b5f2ffe90ec0dd9823744e0-46a962fbb7947b68059374ddde7f29b5490a6b4d
* Install Postman, get it here - https://www.getpostman.com


# The Logic App solution

Create a HTTP Request Step, click save - you will receive an endpoint upon save. 

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/HTTP%20Request.jpg)

You can now invoke your logic app with Postman - add the URL and select POST. Ensure you have set the Header "Content-Type" with value "application/json". Select body, select "raw" and enter the follow value for your body content:

{
  "APIMKey": "[Your APIM Key goes here]",
  "id": 1
}

![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/PostManHeaders.jpg)
![alt text](https://github.com/shanepeckham/CADHackathon_Loyalty/blob/master/Images/PostManBody.jpg)

Now add a step to include an API Management API - select your API "Contact List API"

You will need to navigate to the code view to be able to select the json fields that will be posted as part of the body. Your code view should look like this:

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


