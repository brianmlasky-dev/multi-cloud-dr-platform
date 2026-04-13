<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_run_v2_service_iam_member.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_compute_firewall.allow_http_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.standby](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_kms_crypto_key.storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_binding.storage_encryption](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_binding) | resource |
| [google_kms_key_ring.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_sql_database.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_storage_bucket.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_project_service_account.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_image"></a> [app\_image](#input\_app\_image) | Docker image URI for Cloud Run service | `string` | `"nginx:1.27.4"` | no |
| <a name="input_cloud_run_max_instances"></a> [cloud\_run\_max\_instances](#input\_cloud\_run\_max\_instances) | Maximum number of Cloud Run instances | `number` | `5` | no |
| <a name="input_cloud_run_min_instances"></a> [cloud\_run\_min\_instances](#input\_cloud\_run\_min\_instances) | Minimum number of Cloud Run instances | `number` | `0` | no |
| <a name="input_cloud_run_public_access"></a> [cloud\_run\_public\_access](#input\_cloud\_run\_public\_access) | When true, grants allUsers invoker access to Cloud Run (set to true during failover activation) | `bool` | `false` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the PostgreSQL database | `string` | `"crestline_db"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Cloud SQL master password | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Cloud SQL master username | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (dev, staging, prod) | `string` | `"prod"` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | GCP Project ID | `string` | `"multi-cloud-dr-platform"` | no |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | Primary GCP region for standby deployment | `string` | `"us-central1"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used for resource naming | `string` | `"multi-cloud-dr"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the GCP VPC subnet | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_run_url"></a> [cloud\_run\_url](#output\_cloud\_run\_url) | Cloud Run service URL |
| <a name="output_cloud_sql_connection_name"></a> [cloud\_sql\_connection\_name](#output\_cloud\_sql\_connection\_name) | Cloud SQL instance connection name |
| <a name="output_cloud_sql_private_ip"></a> [cloud\_sql\_private\_ip](#output\_cloud\_sql\_private\_ip) | Cloud SQL private IP address |
| <a name="output_gcs_bucket_name"></a> [gcs\_bucket\_name](#output\_gcs\_bucket\_name) | GCS DR storage bucket name |
| <a name="output_standby_static_ip"></a> [standby\_static\_ip](#output\_standby\_static\_ip) | GCP global static IP for the standby endpoint (supply this as var.gcp\_standby\_ip in the AWS workspace) |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | GCP VPC network name |
<!-- END_TF_DOCS -->