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

and take a note of the public IP address and ID of the instance. (You can recover these at any time with `terraform output`.). Alternatively, you can run `./create.sh <instance_type>`.

You can then SSH into the instance with:

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

To debug issues with the `startup_commands`, you can SSH into the instance and inspect the output from `tail -f /var/log/cloud-init-output.log`. Bear in mind that the script may still be running in the background.

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

to include the ports you want to make accessible (for example to run a webserver on 80 and 443).
