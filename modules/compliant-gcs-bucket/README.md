# CGE-P Lab 2.4 — Terraform Modules for Compliance (AWS)

Terraform module that encodes NIST 800-53 controls SC-12, SC-13, SC-28, AU-11, CM-6, and AC-3 into a reusable AWS S3 + KMS primitive. Consumers supply business configuration only — the compliance floor is hardcoded inside the module and cannot be turned off. Part of the GRC Engineering Practitioner (CGE-P) certification program by GRC Engineering Club.

## What This Lab Builds

| Resource | Purpose |
|---|---|
| `aws_kms_key` | Customer-managed encryption key with hardcoded 90-day rotation (SC-12/SC-13) |
| `aws_s3_bucket` | Primary data bucket with Object Lock enabled at creation (AU-11) |
| `aws_s3_bucket_server_side_encryption_configuration` | CMEK enforced on every object (SC-28) |
| `aws_s3_bucket_versioning` | Versioning enabled for audit trail and recovery (CM-6) |
| `aws_s3_bucket_public_access_block` | All four public access vectors blocked (AC-3) |
| `aws_s3_bucket_object_lock_configuration` | Retention enforced; prod requires >= 365 days (AU-11) |

## Controls

| Control | What the module enforces |
|---|---|
| SC-12 | Customer-managed KMS key — you own the key, not AWS |
| SC-13 | AES-256 via KMS on every object write |
| SC-28 | SSE-KMS at rest; bucket key enabled to reduce KMS API cost |
| AC-3 | All four public access block flags hardcoded `true` |
| CM-6 | Versioning on; four required tags (`Project`, `Environment`, `ManagedBy`, `ComplianceScope`) merged over consumer tags |
| AU-11 | Object Lock GOVERNANCE retention; prod validated >= 365 days at plan time |

## Repository Structure

```
cgep-lab-2.4/
├── evidence/
│   └── lab-2-4/
│       ├── plan.json
│       └── attestation.json
└── terraform/
    ├── modules/
    │   └── compliant-s3-bucket/
    │       ├── main.tf        # Hardcoded compliance floor
    │       ├── variables.tf   # Consumer-facing interface with validation
    │       ├── outputs.tf     # compliance_attestation output
    │       └── README.md
    └── consumers/
        ├── dev/main.tf         # 30-day retention (applies)
        ├── prod/main.tf        # 365-day retention (plan only)
        └── negative-test/      # prod + 30 days → plan-time failure
```

## Quick Start

```bash
cd terraform/consumers/dev
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

Capture evidence:

```bash
mkdir -p ../../../evidence/lab-2-4
terraform show -json tfplan > ../../../evidence/lab-2-4/plan.json
terraform output -json attestation > ../../../evidence/lab-2-4/attestation.json
```

Run the negative test (no AWS resources created):

```bash
cd ../negative-test
terraform init
terraform plan
```

Cleanup:

```bash
cd ../dev
terraform destroy -auto-approve
```