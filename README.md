# Terraform-Scaling
Scaling launch configurations on aws


# AWS Terraform scaling setup

Auto scaling and launch configurations on aws using terraform.

## Getting Started
Download install and setup terraform using the instructions give on the link below.

https://www.terraform.io/intro/getting-started/install.html

For windows installation download and unzip the executable in c:\windows\system32

### Prerequisites

after instaling init the terraform

create a project directory.

For example:
c:\terraform


using command prompt as administrator go to the project directory.

```
C:\
```

```
cd test2
```
to initialize the terraform setup, use the command below.

```
terraform init
```

init command will download and install the aws plugin.

Create an IAM account with aws-ec2 full access policy and update the Access key and Secret key in variables.tf file.

### Usage

Plan the terraform This will show the list of available configurations changes, validations and resources.

```
terraform plan
```

Apply the changes, This will start the execution of the configurations we have defined.
This will create following:
1. Security group with port 80 and 443, 8080 allowed traffic.
2. Secret ssh keypair
3. Auto scaling LAUNCH configurations 
4. Ec2 instance with ubuntu LTS 16.04 x 2
5. Cloudwatch event alarms
6. Helloworld url 
7. Elastic load balancer

to apply the changes and commit the configuration changes to aws, use the command below


```
terraform apply
```

Once the system deployed, It will give public ip as output.

For example:
elb_dns_name = terraform-SG-MyTerraform-228695413.us-east-2.elb.amazonaws.com
instance_ids = [
    18.221.71.78,
    18.222.127.116

## Running the tests

Put the output public ip in the browser and this must give output below.

```
Hello world!!!
```

### destroy the resources

To terminate the ec2 instance and app

```
terraform destroy
```



## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

