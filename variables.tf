# Required variables
######################################################################
variable "kubeconfig" {
  description = "Kubeconfig for cluster in which the chart will be installed."
}

# Optional variables
######################################################################
variable "enabled" {
  description = "Whether to enable this module. This allows for the chart to be properly uninstalled."
  default     = true
}

variable "name" {
  description = "The name to assign to the chart & temporary resources."
  default     = "certmanager"
}

variable "chart_name" {
  description = "The name of the chart to install."
  default     = "stable/cert-manager"
}

variable "chart_version" {
  description = "Version of the Chart."
  default     = "0.0.1"
}

variable "namespace" {
  description = "The namespace to install the chart to."
  default     = "default"
}

variable "helm-extra-args" {
  description = "Extra arguments to pass to helm command."
  default = ""
}

variable "values" {
  description = "Content of Helm values file rendered as a string."
  default = ""
}

# Extra Lifecycle commands
######################################################################
variable "pre-install-cmds" {
  description = "Custom commands to run before installing chart."
  default     = ""
}

variable "post-install-cmds" {
  description = "Custom commands to run after installing chart."
  default     = ""
}

variable "pre-destroy-cmds" {
  description = "Custom commands to run before running `helm delete --purge`."
  default     = ""
}

variable "post-destroy-cmds" {
  description = "Custom commands to run after running `helm delete --purge`."
  default     = ""
}

######################################################################
variable "depends_on" {
  description = "Dummy variable to enable module dependencies."
  default     = []
  type        = "list"
}

output "dependency" {
  description = "Dummy output to enable module dependencies."
  sensitive   = true
  value       = "${var.name}"
}
