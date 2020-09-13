Shipt Project
---------------

------------------------------------------------------------------------------
|Tools:
|-------
|<b>AWS + Azure DevOps + Terraform + Docker + ShellScripting + Git<b>
-------------------------------------------------------------------------------

<b>This configuration, do launch the ASG, ELB and Redis in 2 Regions.<b>

<b>Below is the basic explanation about the set up in one region to get some idea.<b>

Auto Scaling Group with ELB and Redis
--------------------------------------
Configuration in this directory creates Launch Configuration, Auto Scaling Group, Elastic Load Balancer, Redis and attach the Auto Scaling EC2 instances to ELB and creates Redis in private subnet.

How To Run:
-----------

To run this you need to execute:

$ terraform init

$ terraform plan

$ terraform apply --auto-approve

Note: This may create resources which cost money. Run "terraform destroy --auto-approve" when you don't need these resources.

VPC:
----
--> First create VPC with 2 public and 2 private subnets and place then in 2 avaiblility zones
   
    Ex: private-a  us-east-2a
        private-b  us-east-2b
   
        public-a   us-east-2a
        public-b   us-east-2b
        
--> Enable DNS Hostnames in VPC Actions tab and then got to subnets and select public subnets and modify ip assign settings from Action tab and select Auto Assign IP4. This enables public ip and DNS names for only public instance.
 
--> Create 2 Route Tables public and private and point subnets accordingly

--> Create Internet Gateway and add in public route table

--> Create NAT Gateway and point to any one public subnet and then add NAT Gateway in private route table.

EC2(Optional):
-------------- 

--> Go to "ec2_instance" folder and lanch EC2 instance in public subnet(modify variables accoring to your VPC subnet details) 

Auto Scaling and ELB:
---------------------

--> main.tf is main module file for auto scaling group and elb

--> files are in modules/autoscaling and modules/elb

--> we need to update EC2 instance id in ELB variables and modfy the rest of the details according to your VPC and your autoscaling group size

--> This will launch autoscaling group and elb and attach autoscaling group to elb and attach the ec2 instance to elb as well

Redis:
------

--> main.tf file creates redis DB as well

--> files are in modules/redis folder and variables needs to be modified according to your req. 

How TO Test:
-------------

--> once creation part is complete, copy ELB DNS url and paste it in browser and refresh continously. you will see different response from public and private instance. 

   Ex: 
             
       Deployed via Terraform..Private Instance
       ip-10-0-0-21
       
       Deployed via Terraform..Public Instance
       ip-10-0-0-61
       
  --> You can SSH in to Public instance by using public ip but you can't SSH to private instance diectly because you won't get public ip for private instances.

Azure DevOps:
-------------
  We can set up build for above configuration in Azure DevOps which will connect to AWS and creates above services.

Set Up:
------
--> Login to AWS Console and Create IAM user with proper access

--> Create S3 bucket and DynamoDB table in AWS Console to store terraform state and lock the file while executing terraform commands and update values in backend.tf file

--> Now Login into Azure DevOps Portal

--> download toolkit from market place
 
     --> https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-vsts-tools

--> create "service configuration" in "project settings" in Repos page and add AWS IAM credentials here

--> clone the git repo to Repos in azure

--> create a pipeline job
 
--> run the pipeline with pipeline.yaml file

--> Build will connect to AWS and Creates the services and store the terraform state file in S3

<b>Note: All files need to be modify according to your VPC details and update variables accordingly.<b>
   ----
