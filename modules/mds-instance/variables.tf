## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domain" {
  description = "The Availability Domain of the instance. "
  default     = ""
}

variable "display_name" {
  description = "The name of the instance. "
  default     = ""
}

variable "subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = ""
}

variable "mysql_shape" {
  description = "Instance shape to use."
  default     = "MySQL.VM.Standard.E3.1.8GB"
}

variable "admin_username" {
  description = "Username od the MDS admin account"
}


variable "admin_password" {
  description = "Password for the admin user for MDS"
}

variable "configuration_id" {
  description = "MySQL Instance Configuration ID"
}

variable "mysql_is_highly_available" {
  default = false
}

variable "mysql_data_storage_in_gb" {
  default = 50
}

variable "defined_tags" {
  description = "Defined tags for MDS Instance."
  default     = ""
}