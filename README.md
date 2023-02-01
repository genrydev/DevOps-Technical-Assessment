# DevOps Technical Assessment

This code is the response to DevOps Technical Assessment. You can read the assesment description [here](./DevOps_Technical_Assessment.pdf).

This repository contains three main codes:
- API Restful App develop in python using FastAPI library
- Terraform infrastructure deployment for Azure
- CI/CD of APP and Terraform using Github Actions

## APP

### Endpoints

- Test Endpoint: https://catest.whitetree-7a29108d.eastus.azurecontainerapps.io
- Production Endpoint: https://caprod.whitetree-7a29108d.eastus.azurecontainerapps.io

Only the POST to *[Endpoint]/DevOps* is available. Any other method or url will return "ERROR".

In the request you have to add the http header **X-Parse-REST-API-Key** with value **2f5ae96c-b558-4c7b-a590-a501ae1c3f6c**, in other case the service response with http code **403 Forbidden** and the json body *{"detail":"Could not validate API KEY"}*

In the POST request the following example JSON are expected:

```
{
"message" : "This is a test",
"to": "Juan Perez",
"from_": "Rita Asturia",
"timeToLifeSec" : 45
}
```

*Important Note: Look the "from_" key need underscore "_", this is because in python "from" is a reserved word.*

Any other JSON structure will return "ERROR".

The endpoint will return JSON like this:

```
{
"message" : "Hello Juan Perez your message will be send"
}
```

And two important headers:

- *x-app-version*: The APP version based on commit. This can be used for validate that the app version is the expected. 
- *x-container-instance-id*: The container ID that handle the request. This can be used for validate that more than one instance is running for the app.

Full request example:

```
curl -X POST \
  -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
  -H "Content-Type: application/json" \
  -d '{ "message" : "This is a test", "to": "Juan Perez", "from_": "Rita Asturia", "timeToLifeSec" : 45 }' \
  https://${ENDPOINT}/DevOps
```

Finally, the [Dockerfile](./Dockerfile) show how you can build a docker image for this app.

## Terraform

All about Terraform infrastructure deployment you can find in *infrastructure-deployment* folder.

The created resources are:
- **Azure Resource Group** for put all necesary resources inside
- **Azure Container Registry** for docker image storage
- **Azure Log Analytics Workspace**
- **Azure Container App Environment**
- **Azure Container App** for deploy the app, one for test and one for prodcution.

## CI/CD

### APP

The App pipeline is [here](./.github/app-ci-cd.yml).

### Terraform

The Terraform pipeline is [here](./.github/terraform.yml).