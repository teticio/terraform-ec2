# Terraform EC2

Terraform code to quickly spin up / tear down an EC2 instance in AWS. A persistent EBS volume is also created and mounted at `/home`.

## Usage

Ensure you have a public key (for example in `~/.ssh/id_rsa.pub`). If not, you can create one with:
    
```bash
ssh-keygen
```

Create a `terraform.tfvars` file:

```terraform
region          = "eu-west-2"         # AWS region
instance_type   = "t2.micro"          # EC2 instance type
volume_size     = 20                  # Size of home EBS volume in GB
public_key_path = "~/.ssh/id_rsa.pub" # Path to public key
ingress_ports   = [22]                # Ports to open

# Commands to run on startup (e.g. to install pip)
startup_commands = [
  <<-EOL
    apt-get update
    apt-get install -y python3-pip
  EOL
]
```

Then run:

```bash
terraform init
terraform apply -auto-approve
```

and take a note of the public IP address and ID of the instance. (You can recover these at any time with `terraform output`.) Alternatively, you can run `./create.sh <instance_type>`.

You can then SSH into the instance with

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

If you re-run the apply or `./create.sh` command, Terraform will create a new instance with a new public IP address and attach the existing EBS volume to it. Note that your home EBS volume will persist and you will be charged $0.10 per GB-month whether or not it is attached to an EC2 instance (until you run `terraform destroy -auto-approve`).

To debug issues with the `startup_commands`, you can SSH into the instance and inspect the output from `tail -f /var/log/cloud-init-output.log`. Bear in mind that the script may still be running in the background. To wait for the script to finish run `cloud-init status --wait`.

## Grow your own EBS

To increase your the size of your EBS volume without destroying your data, first change the `volume_size` variable in `terraform.tfvars`, run `terraform apply -auto-approve` and connect to your instance. In the instance, run:

```bash
if [ -e /dev/xvda ]; then
    sudo resize2fs /dev/xvda
else
    sudo resize2fs /dev/nvme1n1
fi
```

You can then run `df -h /home` to check that the volume has been resized.

## Opening ports

You can, of course, tunnel to any port via SSH on port 22 with

```bash
ssh -L <local_port>:localhost:<remote_port> ubuntu@<public_ip>
```

but, if you want to open ports to the public, just set the variable

```terraform
ingress_ports   = [22, 80, 443]       # Ports to open
```

to include the ports you want to make accessible (for example to run a web server on 80 and 443).

# Bring your own AMI

If you plan to always install the same packages every time you spin up an instance, you can create your own AMI with the packages pre-installed by running the following commands:

```bash
instance_id=$(terraform output -json | jq -r '.instance_id.value')
aws ec2 stop-instances --instance-ids $instance_id
aws ec2 wait instance-stopped --instance-ids $instance_id
# Detach home EBS volume, otherwise a snapshot will be created
volume_id=$(terraform output -json | jq -r '.home_ebs_volume.value')
aws ec2 detach-volume --volume-id $volume_id
aws ec2 wait volume-available --volume-id $volume_id
ami_id=$(aws ec2 create-image --instance-id $instance_id --name "my_ami" --query 'ImageId' --output text)
aws ec2 wait image-available --image-ids "$ami_id"
```

Then add the following lines to `terraform.tfvars` to select your AMI next time you spin up an instance:

```terraform
ami_owner       = "self"              # Owner of AMI
ami_name        = "my_ami"            # Name of AMI
```
