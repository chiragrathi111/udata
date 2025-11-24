Assume IAm Role for user:-

If you want to use this feature
First create a new user and create a new Iam role, this time we have multiple type which type you want to create a iam role,
so we are createing iam for assume to user so we are selecting AWS account not AWS service
then go to next and select policy and enter role name and create, role createion completed.
We again go to user and click user name then select inline policy and write the json 

{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": "sts:AssumeRole",
			"Resource": "PASTE ROLE ARN"
		}
	]
} 


This policy import because without this step we cannot gave access to user and policy

This policy have limitiation you not gave access to standard url
you just go to role page then slect you own role,inside role you see Link to switch role in console
select this link and you got access for specific service.



{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificInstance",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances"
      ],
      "Resource": "arn:aws:ec2:ap-south-1:ACCOUNT-ID:instance/i-0bcbe2b9d9476039c"
    },
    {
      "Sid": "AllowDescribeForConsole",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeInstanceStatus"
      ],
      "Resource": "*"
    }
  ]
}


----------------------------------------------------------
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowOnlyTaggedInstanceActions",
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances",
        "ec2:DescribeInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Project": "Client1"
        }
      }
    },
    {
      "Sid": "AllowBasicDescribe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeInstanceStatus"
      ],
      "Resource": "*"
    }
  ]
}
------------------------------------------------------------------
=VwJI6G.y4MMTJA!L%z@idz&PWMH*M4w
