## EBS with terraform and connecting it with EC2
### In this document , we are going to 
- launch an instance 
- create one ebs volume 
- attach ebs ti instance
-----------------------------------
first check instances and volumes on aws cloud

-------------------
## Create instance 

```
provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQCPTC4HGT2LF2GQT"
  secret_key = "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"
}

# creating a instance 
resource "aws_instance" "for-ebs" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
 
    tags = {
      Name = "ebs"
    }
}


```
### print the detailes of instance

```
output "EC2_detailes" {
  value = aws_instance.for-ebs
}

```

## create a ebs volume 

```
#create a ebs volume 

resource "aws_ebs_volume" "ebs" {
  availability_zone = aws_instance.for-ebs.availability_zone
  size = 1
  tags = {
    Name = "EBS"
  }
}


```
### print detailes of ebs as well

```
output "ebs_detailes" {
  value = aws_ebs_volume.ebs
}
```

---------
-----------

Run following commands 

- **terraform init**
- **terraform validate**
- **terraform plan**
- **terraform apply**

----


*what is going to happen*
![alt text](image.png)

-----------

*check aws console named ebs*
![alt text](image-1.png)

-------------

*check for ebs volumes named EBS*

![alt text](image-2.png)

--------------------

-  an instance is launced with root volume of 8gb. and an ebs volume is also created, 
-  now we have to attach the ebs volume to ec2 instance

-  by default the root volume which has been created with instance is availabe.
-  to make our new created ebs volume available, we have to attach it to the instance.
-----------------

## to attach second volume , we require ec2 instance id and volume ebs id.

### first check ec2 volumes
![alt text](image-3.png)

## further code below

```
# attaching second volume to ec2 instance

resource "aws_volume_attachment" "ebs-to-ec2" {
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.ebs.id
    instance_id = aws_instance.for-ebs.id
}

```

---------------

- run **terraform plan**
- run **terraform apply**

![alt text](image-4.png)

----------------

*what is happening here*
## check for ec2 storage volumes again 
![alt text](image-5.png)

--------------