# CGE-P Lab 2.3 — Building Your First Compliant Resource (AWS S3)

Terraform deployment of a NIST 800-53 compliant AWS S3 bucket built as part of the GRC Engineering Practitioner (CGE-P) certification program by GRCEngClub.

## What This Lab Does

Provisions a primary data bucket and a dedicated log bucket with the following controls enforced:

| Control | Implementation |
|---|---|
| SC-28 | AES-256 server-side encryption on both buckets |
| AC-3 | All four public access vectors explicitly blocked |
| CM-6 | Versioning enabled; mandatory compliance tags applied at the provider level |
| AU-3 / AU-6 | Server access logging routed from the primary bucket to a dedicated log bucket |

Infrastructure is fully managed by Terraform (AWS provider v5) and follows the modular directory structure used throughout the CGE-P capstone.

## Repository Structure

```
cgep-lab-2.3/
├── evidence/
│   └── lab-2-3/
│       ├── plan.json     # terraform show -json tfplan (pre-deploy intent)
│       └── state.json    # terraform show -json (post-deploy state)
└── terraform/primitives/compliant-s3/
    ├── main.tf           # All 11 AWS resources
    ├── variables.tf      # project_name, environment, bucket_suffix
    ├── outputs.tf        # Bucket ARNs + SC-28 attestation output
    └── README.md         # Usage and cleanup commands
```

## Compliance Evidence

Machine-readable JSON artifacts are captured via `terraform show -json` and stored in `evidence/lab-2-3/`. These files serve as audit evidence — no screenshots required.

| File | Purpose |
|---|---|
| `evidence/lab-2-3/plan.json` | Pre-deploy intent — what Terraform planned to create |
| `evidence/lab-2-3/state.json` | Post-deploy state — what AWS confirmed exists |

Key evidence paths in `state.json`:

- **SC-28**: `server_side_encryption_configuration[].rule[].apply_server_side_encryption_by_default[].sse_algorithm = "AES256"`
- **AC-3**: `public_access_block` — all four flags `true`
- **CM-6**: `tags_all` — `Project`, `Environment`, `ManagedBy`, `ComplianceScope` on every resource
- **AU-3**: `aws_s3_bucket_logging.primary.target_bucket`

## Quick Start

```bash
cd terraform/primitives/compliant-s3

terraform init
terraform validate
terraform plan -var="project_name=cgep-lab" -var="environment=dev" -out=tfplan
terraform apply -auto-approve tfplan
```

Capture evidence:

```bash
mkdir -p evidence/lab-2-3
terraform show -json tfplan > evidence/lab-2-3/plan.json
terraform show -json        > evidence/lab-2-3/state.json
```

Cleanup:

```bash
terraform destroy -var="project_name=cgep-lab" -var="environment=dev"
```

## Part of the CGE-P Certification

This lab is part of the [GRC Engineering Practitioner (CGE-P)](https://github.com/GRCEngClub/cgep-labs) certification program by GRCEngClub. The modular structure built here is reused and extended through Chapter 7's capstone.