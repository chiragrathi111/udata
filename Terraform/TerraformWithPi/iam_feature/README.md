# IAM User and Group Management with Terraform

This Terraform configuration creates a comprehensive IAM setup with users, groups, policies, MFA enforcement, and password policies based on CSV data.

## Features

- **Bulk User Creation**: Creates users from CSV file
- **Automatic Group Assignment**: Users assigned to groups based on department/role
- **MFA Enforcement**: All users must enable MFA to access AWS
- **Strong Password Policy**: Account-wide password requirements
- **Role-Based Permissions**: Different policies for each group
- **Secure Password Generation**: Random passwords with forced reset

## Architecture

### Users
- Created from `users.csv` file
- Username format: `firstname_lastname` (lowercase)
- Each user gets login profile with random password
- MFA device created for each user

### Groups
- **Education**: Read-only access to training resources
- **Sales**: Access to customer data and CRM systems  
- **Corporate**: Administrative access with restrictions
- **Managers**: Cross-departmental reporting and oversight

### Security Features
- **MFA Required**: Users cannot access AWS without MFA setup
- **Strong Passwords**: 12+ characters, mixed case, numbers, symbols
- **Password Rotation**: 90-day expiration, prevents reuse of last 5 passwords
- **Least Privilege**: Each group has minimal required permissions

## Files Explanation

### `main.tf`
- **aws_iam_user**: Creates users from CSV data with tags
- **aws_iam_user_login_profile**: Generates secure passwords (12 chars)
- **aws_iam_virtual_mfa_device**: Creates MFA device for each user

### `groups.tf`
- **aws_iam_group**: Creates 4 groups (Education, Sales, Corporate, Managers)
- **aws_iam_group_membership**: Auto-assigns users based on department/role tags

### `policies.tf`
- **Department Policies**: Specific permissions for each group
- **MFA Policy**: Enforces MFA for all operations (except MFA setup)
- **Policy Attachments**: Links policies to appropriate groups

### `password_policy.tf`
- **aws_iam_account_password_policy**: Account-wide password requirements
- Enforces strong passwords for all IAM users

### `users.csv`
- Source data for user creation
- Columns: first_name, last_name, department, job_title
- Used for automatic group assignment

## Key Improvements Made

### 1. **Enhanced Password Security**
```hcl
# Before: Basic password creation
password_reset_required = true

# After: Strong password with specific length
password_length         = 12
password_reset_required = true
```

### 2. **MFA Device Creation**
```hcl
# Added: Virtual MFA device for each user
resource "aws_iam_virtual_mfa_device" "user_mfa" {
  virtual_mfa_device_name = each.value.name
  path = "/mfa/"
}
```

### 3. **Comprehensive Policies**
- **Before**: No policies attached to groups
- **After**: Role-specific policies + MFA enforcement for all groups

### 4. **Better Group Assignment**
```hcl
# Improved: More specific role matching for managers
users = [for user in aws_iam_user.user : user.name 
         if contains(["Regional Manager", "CEO", "CFO"], user.tags["Role"])]
```

### 5. **Account-Wide Security**
- Added password policy affecting all users
- Enforces complexity, rotation, and reuse prevention

## Usage Instructions

### 1. **Deploy Infrastructure**
```bash
terraform init
terraform plan
terraform apply
```

### 2. **User Onboarding Process**
1. **Get Password**: Admin retrieves temporary password from Terraform output
2. **First Login**: User logs in and must change password
3. **Setup MFA**: User must configure MFA device before accessing resources
4. **Access Resources**: User can now access AWS based on group permissions

### 3. **MFA Setup for Users**
1. Login to AWS Console with temporary password
2. Go to IAM → Users → [Username] → Security credentials
3. Assign MFA device using the QR code from Terraform output
4. Complete MFA setup to gain full access

## Security Best Practices Implemented

### ✅ **Password Security**
- 12+ character minimum length
- Requires uppercase, lowercase, numbers, symbols
- 90-day rotation policy
- Prevents reuse of last 5 passwords

### ✅ **MFA Enforcement**
- All users must enable MFA
- Cannot perform any actions without MFA (except MFA setup)
- Virtual MFA devices created automatically

### ✅ **Least Privilege Access**
- Each group has minimal required permissions
- Corporate group denied user management actions
- Region restrictions where applicable

### ✅ **Audit and Monitoring**
- All resources tagged for tracking
- User creation tracked via Terraform
- Group memberships clearly defined

## Common Issues and Solutions

### Issue 1: "Access Denied" after user creation
**Cause**: User hasn't set up MFA yet
**Solution**: User must configure MFA device before accessing resources

### Issue 2: Password doesn't meet requirements
**Cause**: Account password policy is strict
**Solution**: Use generated password or create one meeting all requirements

### Issue 3: User not in expected group
**Cause**: CSV data doesn't match group assignment logic
**Solution**: Check department/role values in CSV match the filtering logic

## Customization

### Adding New Users
1. Add user to `users.csv`
2. Run `terraform plan` and `terraform apply`
3. User automatically assigned to appropriate groups

### Modifying Policies
1. Edit policies in `policies.tf`
2. Apply changes with `terraform apply`
3. Changes take effect immediately

### Changing Password Policy
1. Modify variables in `variable.tf`
2. Apply with `terraform apply`
3. Affects all future password changes

## Security Warnings

⚠️ **Never commit passwords or keys to version control**
⚠️ **MFA QR codes contain sensitive data - handle securely**  
⚠️ **Review group permissions before applying in production**
⚠️ **Test user access in non-production environment first**

## Cleanup

```bash
terraform destroy
```

**Note**: This will delete all users, groups, and policies. Ensure you have backups of any important data.