# IAM Groups for different departments and roles
# Groups allow us to manage permissions at scale

# Education group - for training and educational staff
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

# Sales group - for sales representatives and sales staff
resource "aws_iam_group" "sales" {
  name = "Sales"
  path = "/groups/"
}

# Corporate group - for executives and corporate leadership
resource "aws_iam_group" "corporate" {
  name = "Corporate"
  path = "/groups/"
}

# Managers group - for people in management roles across departments
resource "aws_iam_group" "managers" {
  name = "Managers"
  path = "/groups/"
}

# Group Memberships - Automatically assign users to groups based on their tags
# This uses for loops to dynamically assign users based on CSV data

# Education group membership - users with Department = "Education"
resource "aws_iam_group_membership" "education_members" {
  name = "Education-Group-Membership"
  group = aws_iam_group.education.name
  
  # Filter users: only those with Education department tag
  users = [for user in aws_iam_user.user : user.name if user.tags["Department"] == "Education"]
}

# Sales group membership - users with Department = "Sales"
resource "aws_iam_group_membership" "sales_members" {
  name = "Sales-Group-Membership"
  group = aws_iam_group.sales.name
  
  # Filter users: only those with Sales department tag
  users = [for user in aws_iam_user.user : user.name if user.tags["Department"] == "Sales"]
}

# Corporate group membership - users with Department = "Corporate"
resource "aws_iam_group_membership" "corporate_members" {
  name = "Corporate-Group-Membership"
  group = aws_iam_group.corporate.name
  
  # Filter users: only those with Corporate department tag
  users = [for user in aws_iam_user.user : user.name if user.tags["Department"] == "Corporate"]
}

# Managers group membership - users with management roles across all departments
resource "aws_iam_group_membership" "managers_members" {
  name = "Managers-Group-Membership"
  group = aws_iam_group.managers.name

  # Filter users: anyone with "Manager" or "CEO" in their role
  # This creates cross-departmental management group
  users = [for user in aws_iam_user.user : user.name if contains(["Regional Manager", "CEO", "CFO", "Vice President of Northeast Sales", "Vice President of the Northeast Region", "Coordinating Director of Emerging Regions"], user.tags["Role"])]
}