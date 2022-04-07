## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "current_user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "twitter_oauth_accessToken" {}
variable "twitter_oauth_accessTokenSecret" {}
variable "twitter_oauth_consumerKey" {}
variable "twitter_oauth_consumerSecret" {}

variable "twitter_filter" {
  default = "India"
}

variable "ocir_user_name" {}
variable "ocir_user_password" {}

variable "bucket_name" {
  default = "tweets_ai_bucket"
}

variable "source_stream_name" {
  default = "tweets"
}

variable "target_stream_name" {
  default = "key_phrases"
}

variable "stream_partitions" {
  default = "1"
}

variable "stream_pool_name" {
  default = "tweets_pool"
}

variable "sch_connector_name" {
  default = "sch_AI_processing"
}

variable "service_connector_tasks_batch_size_in_kbs" {
  default = 128
}

variable "service_connector_tasks_batch_time_in_sec" {
  default = 60
}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "subnet-CIDR" {
  default = "10.0.1.0/24"
}


variable "ocir_repo_name" {
  default = "functions"
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "instance_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "instance_flex_shape_ocpus" {
  default = 1
}

variable "instance_flex_shape_memory" {
  default = 10
}

variable "public_ssh_key" {
  default = ""
}

variable "generate_public_ssh_key" {
  default = true
}

variable "private_ssh_key_path" {
  default = ""
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.instance_shape)
}

data "oci_identity_regions" "oci_regions" {

  filter {
    name   = "name"
    values = [var.region]
  }

}

locals {
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = data.oci_identity_tenancy.current_user_tenancy.name
}

