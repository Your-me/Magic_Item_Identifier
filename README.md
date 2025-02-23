# Magic_Item_Identifier
Using AWS LAMBDA and API-GATEWAY to trigger a request with a magic item name as a query parameter and fetch the properties of the item.

# Magic Item Identifier Pipeline

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-1.5.0-purple?style=flat-square)
![Python](https://img.shields.io/badge/python-3.9-blue?style=flat-square)
![AWS](https://img.shields.io/badge/AWS-Pip?style=flat-square)

This repository contains a CI/CD pipeline for deploying a Magic Item Identifier API using GitHub Actions, Terraform, and AWS services.

## Pipeline Overview

The pipeline consists of three main jobs:
- **Test**: Runs Python unit tests and checks code coverage.
- **Terraform Plan**: Validates infrastructure and creates a Terraform execution plan.
- **Deploy**: Deploys the infrastructure, updates REST API documentation, and runs integration tests.

## Environment Variables

```yaml
AWS_REGION: eu-west-2
TERRAFORM_VERSION: 1.5.0
PYTHON_VERSION: 3.9
TF_STATE_BUCKET_NAME: from secrets
WORKING_DIR: Infra_Serverless

## Required GitHub Secrets

| Secret                     | Description                      |
|----------------------------|----------------------------------|
| `AWS_ACCESS_KEY_ID`        | AWS Access Key                   |
| `AWS_SECRET_ACCESS_KEY`    | AWS Secret Key                   |
| `AWS_TF_STATE_BUCKET_NAME` | S3 Bucket for Terraform State    |

## Jobs Structure

### Test Job
- **Checkout Repository**: Uses the latest code.
- **Set up Python**: Configures Python 3.9 environment.
- **Install Dependencies**: Installs required Python packages.
- **Create Test File**: Generates a test file for Lambda function.
- **Run Tests**: Executes unit tests with coverage.

### Terraform Plan
- **Checkout Repository**: Uses the latest code.
- **Configure AWS Credentials**: Sets up AWS access.
- **Setup Terraform**: Prepares Terraform environment.
- **Terraform Init**: Initializes Terraform with backend configuration.
- **Terraform Format**: Ensures code formatting.
- **Terraform Validate**: Validates Terraform configuration.
- **Terraform Plan**: Creates and uploads a Terraform plan.

### Deploy
- **Checkout Repository**: Uses the latest code.
- **Configure AWS Credentials**: Sets up AWS access.
- **Setup Terraform**: Prepares Terraform environment.
- **Terraform Init**: Initializes Terraform with backend configuration.
- **Terraform Apply**: Create the infrastructure.
- **Get API URL**: Extracts and validates the API URL.
- **Update REST File**: Updates the REST file with the new API URL.
- **Install Rest Client Plugin on Vscode**:To use REST file, Rest.client plugin must be install on VScode. The yout client on rest to see the generated output
- **Commit and Push REST File**: Commits changes to the repository.
- **Test Deployment**: Runs integration tests on the deployed API.

## API Endpoints

### Get Item Details
```http
GET https:api_url/item?name={itemName}
```

### Get Random Item
```http
GET https:api_url/item?name=random
```

- **Check the api-test.rest in infra_serverless dir for implementation**.


## Testing

### Local Testing for the lambda_function wriiten in python
```bash
# Install dependencies
pip install pytest pytest-cov requests

# Run tests
pytest test_lambda.py --cov=lambda_magic_item_identifier -v
```

## Deployment

### Automatic Deployment
- Triggered on push to the main branch.
- Requires passing tests and a successful Terraform plan.

## Monitoring

- **CloudWatch Logs**: Monitors Lambda function execution.
- **API Gateway Metrics**: Tracks API usage and performance.

## Troubleshooting

### Common Issues

1. **API URL Format Error**
   - Check the API URL format in Terraform output.

2. **Terraform State Issues**
   - Verify S3 bucket access and state file locking.

3. **Lambda Deployment Issues**
   - Check Lambda logs in CloudWatch.