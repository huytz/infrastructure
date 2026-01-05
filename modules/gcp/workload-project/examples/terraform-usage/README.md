# Terraform Usage Example

Example showing how to use the workload-project module directly with Terraform.

## Usage

1. **Initialize:**
   ```bash
   terraform init
   ```

2. **Create terraform.tfvars:**
   ```hcl
   billing_account_id   = "01ABCD-2EFGH3-4IJKL5"
   organization_id      = "123456789012"
   foundation_project_id = "foundation-project-abc123"
   ```

3. **Deploy:**
   ```bash
   terraform plan
   terraform apply
   ```

## Customization

Edit `main.tf` to change team names, add/remove teams, or customize tags.
