# Terraform EC2

Terraform code to quickly spin up an EC2 instance in AWS. A persistent EBS volume is also created and mounted at `/home`.

## Usage

Ensure you have a public key in `~/.ssh/id_rsa.pub`. If not, you can create one with:
    
```bash
ssh-keygen
```

Create a `terraform.tfvars` file:

```terraform
region          = "eu-west-2"         # AWS region
instance_type   = "t2.micro"          # EC2 instance type
volume_size     = 20                  # Size of home EBS volume in GB
public_key_path = "~/.ssh/id_rsa.pub" # Path to public key
```

Then run:

```bash
terraform init
terraform apply -auto-approve
```

and take a note of the public IP address and ID of the instance. (You can recover these at any time with `terraform output`.). Alternatively, you can run `./create.sh <instance_type>`.

The script in `bootstrap.sh` will be run on startup. This mounts the persistent EBS volume at `\home` and can be used to install any packages you want. You can then SSH into the instance with:

```bash
ssh ubuntu@<public_ip>
```

or simply `./connect.sh`.

You can terminate the instance from the command line by running:

```bash
aws ec2 terminate-instances --instance-ids <instance_id>
aws ec2 wait instance-terminated --instance-ids <instance_id>
```

or `./terminate.sh`.

If you re-run the apply command, Terraform will create a new instance with a new public IP address. Note that your home EBS volume will persist until you run `terraform destroy -auto-approve`. If you simply change the instance type in `terraform.tfvars` and re-run `terraform apply -auto-approve`, Terraform will create a new instance and attach the existing EBS volume to it.
