variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = "cgep-lab-fabrizio"
}

variable "github_repo" {
  description = "GitHub repository allowed to use Workload Identity Federation"
  type        = string
  default     = "fdicarlo/cgep-compliance-engineering-labs"
}