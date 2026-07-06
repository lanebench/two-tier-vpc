# Two-Tier VPC Architecture on AWS

A secure two-tier network built with Terraform: a public-facing web server and a fully isolated private database, with zero SSH keys anywhere in the design.

## The problem this solves

A lot of small/mid-size deployments still run everything in a single flat network — including databases that have no business being internet-reachable. This project demonstrates the standard AWS security pattern: only the resource that needs public access gets it, everything else stays reachable only from inside the network.

## Architecture

- **VPC** (`10.0.0.0/16`) spanning multiple Availability Zones
- **Public subnet** — EC2 instance running nginx, reachable over HTTP, routed through an Internet Gateway
- **Private subnets** (two, in separate AZs — required by AWS for RDS subnet groups) — MySQL RDS instance, no public IP, reachable only from the EC2 security group
- **NAT Gateway** — gives the private subnet outbound-only internet access (patching, updates) with zero inbound path
- **AWS Systems Manager (SSM) Session Manager** — used instead of SSH for shell access to EC2. No key pairs, no open port 22, authentication handled entirely through IAM
- **AWS Secrets Manager** — RDS master password is generated and managed by AWS directly (`manage_master_user_password = true`), never stored in Terraform state, `.tfvars`, or anywhere in plaintext

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Connect to EC2 (no SSH key required):

```bash
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
```

## Real troubleshooting encountered

- **SSM agent registered as "not connected" despite correct IAM role.** Root cause: the instance profile was attached to an already-running instance rather than at launch, so the agent never re-checked for it. Fix: `aws ec2 reboot-instances` forces re-registration. Diagnosed by ruling out, in order: instance profile attachment, IAM policy attachment, security group egress, and route table — all four checked out clean before landing on the actual cause.
- **RDS subnet group requires two Availability Zones**, even for a single-AZ instance — Terraform apply fails outright if both private subnets share an AZ.
- **MySQL usernames are case-sensitive** — `-u Admin` failed against a `username = "admin"` resource.
- **zsh interprets `!` as history expansion** — Secrets Manager ARNs for RDS-managed secrets contain `!` (e.g. `rds!db-...`), which breaks unless wrapped in single quotes.

## Cost considerations

| Resource | Approx. cost while running |
|---|---|
| NAT Gateway | ~$0.045/hr + data processing (~$1-1.50/day idle) |
| RDS (db.t3.micro) | ~$0.017/hr |
| EC2 (t2.micro) | Free tier eligible |
| Secrets Manager | ~$0.40/month per secret |

Torn down with `terraform destroy` after this session.
