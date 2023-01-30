# tfcvlt
This is a demonstration to enable dynamic secrets with [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) and [Vault OSS](https://www.vaultproject.io/) on [Cloud Run](https://cloud.google.com/run).

![Architecture Overview](public/architecture-overview.png)

## Challenge
Terraform is widely used by a lot of developers to manage public cloud resources such as AWS, GCP and Azure.
And as you know, it is an important thing how to manage Terraform's state file when using it.
Many developers will store it in a cloud storage bucket to share it among develoers, and it makes CI/CD pipelines possible to run Terraform.
Furthermore, it is better for securiteis because not storing the state file on your local machine and in source control.

Ideally, you should avoid placing secrets in your Terraform config or state file wherever you stored it as long as possible,
because it is impossible to prevent the leaks completely, these might be due to human errors, vendor's incident or the other factors.
 
For even higher levels of security, every credentials used by Terraform should be short-lived, so that in case someone somehow gets access to the state file.
This prevents malicious users from using those to cause harm.

Vault is useful to enable the above, so let's solve these challenges by leveraging Terraform Cloud and Vault to provide a secure solution for using Dynamic Secret.


## Solution
Terraform asks Vault for service account's credentials rather than setting them as a variable.
And Vault requests Cloud providers to create a service account and handles its' secret with TTL.
This means these are automatically revoked when they are no longer used.

By making those credentials short-lived, you reduce the chance that they might be compromised.
If Terraform's state file was compromised, the credentials used by the terraform can be revoked rather than changing more global sets of credentials.

![Dynamic Secret Flow](public/dynamic-secret.png)

Moreover, Terraform will not output the secrets used for the Vault authentication into your state file.
This means Approle's role_id and secret_id are not exposed to and it's provided easily by using Terraform secure variable store.


## Prerequisites
To perform the next steps, you need to have:

* An HCP account or Terraform Cloud account to login Terraform Cloud.

* Install Vault & Terraform on your local machine.

* An GCP account and GCP project.

* Install Google Cloud CLI(gcloud) to create and manage GCP resources.


## Demonstration
### Enable required APIs
```
gcloud services enable \
--async \
cloudkms.googleapis.com \
run.googleapis.com \
secretmanager.googleapis.com \
storage.googleapis.com \
iam.googleapis.com
```

### Create a short-lived service account to provision Vault server
```
gcloud iam service-accounts create terraform \
--description="This should be removed after enabling the Vault server"
```

To grant your service account an IAM role on your project, run the next command:
```
gcloud projects add-iam-policy-binding knanao \
--member="serviceAccount:terraform@knanao.iam.gserviceaccount.com" --role="roles/owner"
```

To create service account key, run the next command:
```
gcloud iam service-accounts keys create .secrets/credentials.json \
--iam-account=terraform@knanao.iam.gserviceaccount.com
```

To create `ops` workspace, run the command:
```
WORKSPACE=ops make init
```

Place your credentials in a Terraform Cloud environment variable at `ops` workspace, `GOOGLE_CREDENTIALS` as Sensitive.
After that, please delete your local credential file.
```
cat .secrets/credentials.json | tr -s '\n' ' '
```

### Install required components and initialize Vault server
Before running the below command, please update `gcp_project` in the terraform.tfvars each `dev` and `ops` dirs.
```
WORKSPACE=ops make apply
```

If Cloud KMS's key ring already exists, run the import command and retry the above command:
```
make import
```

To update the cloud run service and get an URL, run the next commad:
```
make replace
```

Export the URL as a `VAULT_ADDR` and use curl to retrieve the status of the Vault server:
```
curl -s -X GET ${VAULT_ADDR}/v1/sys/seal-status -H "Authorization: Bearer $(gcloud auth print-identity-token)" | jq .
```

After installing required components, initialize Vault server.
```
curl -s -X PUT \
  ${VAULT_ADDR}/v1/sys/init \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  --data @payload.json | jq .
```

Make Vault server public to access to it from Terraform Cloud.
```
gcloud run services add-iam-policy-binding vault-server \
--member="allUsers" \
--role="roles/run.invoker" \
--region=asia-northeast1
```

Save the URL to Terraform Cloud environment variable at `dev` workspace, `VAULT_ADDR` as a sensitive value.
And export the Vault's root token:
```
export VAULT_TOKEN=__ROOT_TOKEN__
```

You can check Vault's status, If something is wrong, please re-check the env values.
```
vault status
```

To create `dev` workspace, run the command:
```
make init
```

### Logs into Vault using the AppRole auth backend
To create a new policy in Vault:
```
vault policy write terraform infra/dev/terraform-policy.hcl
```

Enable the AppRole auth method:
```
vault auth enable approle
```

Create a named role:
```
vault write auth/approle/role/terraform \ 
secret_id_ttl=0 \
token_num_uses=0 \
token_ttl=0 \
token_max_ttl=0 \
secret_id_num_uses=0 \
policies=terraform
```

Fetch the RoleID of the AppRole:
```
vault read auth/approle/role/terraform/role-id
```
And save `role_id` as Terraform Cloud variable, `login_approle_role_id` as a sensitive value.

Get a SecretID issued against the AppRole:
```
vault write -f auth/approle/role/terraform/secret-id num_uses=0 ttl=0
```
And save `secret_id` as Terraform Cloud variable, `login_approle_secret_id` as a sensitive value.

Finally, configure a secret engine to crete a dynamic secret:
```
make apply
```

### Provision resources using dynamic credentials
Before running this command, please uncomment [google provider](https://github.com/knanao/tfcvlt/blob/main/infra/dev/provider.tf) and [a storage resource](https://github.com/knanao/tfcvlt/blob/main/infra/dev/storage.tf).\
Let's create a gcs with dynamic credentials.
```
make apply
```

### Clean Up
```
make destroy
make cleanup
```

### Debug
To check the dynamic key, run the command:
```
watch -n 1 gcloud iam service-accounts keys list --iam-account=vaultterraform-__ULID__@knanao.iam.gserviceaccount.com
```

To retrive the `lease_id`, run the command:
```
vault read gcp/roleset/terraform/key
```

To revoke the key manually, run the command:
```
vault lease revoke -sync gcp/roleset/terraform/key/__LEASE_ID__
```
