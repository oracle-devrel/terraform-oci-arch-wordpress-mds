## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "mds-instance" {
  source                    = "./modules/mds-instance"
  admin_password            = var.admin_password
  admin_username            = var.admin_username
  availability_domain       = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain_name
  configuration_id          = data.oci_mysql_mysql_configurations.shape.configurations[0].id
  mysql_shape               = var.mysql_shape
  compartment_ocid          = var.compartment_ocid
  subnet_id                 = local.mds_subnet_id
  display_name              = "MySQLInstance"
  mysql_is_highly_available = var.mysql_is_highly_available
  defined_tags              = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
