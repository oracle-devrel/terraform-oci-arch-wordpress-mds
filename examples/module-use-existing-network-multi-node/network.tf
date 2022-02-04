## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "my_vcn" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "my_vcn"
  dns_label      = "myvcn"
}


resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "my_igw"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}


resource "oci_core_nat_gateway" "my_natgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_natgw"
}

resource "oci_core_route_table" "my_public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_public_rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.my_igw.id
  }
}

resource "oci_core_route_table" "my_private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_private_rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.my_natgw.id
  }
}

resource "oci_core_security_list" "my_ssh_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "my_ssh_sec_list"
  vcn_id         = oci_core_virtual_network.my_vcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "my_httpx_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "my_httpx_sec_list"
  vcn_id         = oci_core_virtual_network.my_vcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "my_mds_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "my_mds_sec_list"
  vcn_id         = oci_core_virtual_network.my_vcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "1"
    source   = "192.168.0.0/16"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "192.168.0.0/16"
  }
  ingress_security_rules {
    tcp_options {
      max = 3306
      min = 3306
    }
    protocol = "6"
    source   = "192.168.0.0/16"
  }
  ingress_security_rules {
    tcp_options {
      max = 33061
      min = 33060
    }
    protocol = "6"
    source   = "192.168.0.0/16"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "192.168.0.0/16"

    tcp_options {
      min = 2048
      max = 2050
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "192.168.0.0/16"

    tcp_options {
      source_port_range {
        min = 2048
        max = 2050
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "192.168.0.0/16"

    tcp_options {
      min = 111
      max = 111
    }
  }
}

resource "oci_core_subnet" "lb_subnet_public" {
  cidr_block                 = "192.168.1.0/24"
  display_name               = "lb_subnet_public"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.my_public_rt.id
  security_list_ids          = [oci_core_security_list.my_httpx_sec_list.id]
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "lbsub"
}

resource "oci_core_subnet" "bastion_subnet_public" {
  cidr_block                 = "192.168.2.0/24"
  display_name               = "baston_subnet_public"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.my_public_rt.id
  security_list_ids          = [oci_core_security_list.my_ssh_sec_list.id]
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "bsub"
}

resource "oci_core_subnet" "wp_subnet_private" {
  cidr_block                 = "192.168.3.0/24"
  display_name               = "wp_subnet_public"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.my_private_rt.id
  security_list_ids          = [oci_core_security_list.my_ssh_sec_list.id, oci_core_security_list.my_httpx_sec_list.id]
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "wpsub"
}

resource "oci_core_subnet" "mds_subnet_private" {
  cidr_block                 = "192.168.4.0/24"
  display_name               = "mds_subnet_private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.my_private_rt.id
  security_list_ids          = [oci_core_security_list.my_mds_sec_list.id]
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "mdspriv"
}

resource "oci_core_subnet" "fss_subnet_private" {
  cidr_block                 = "192.168.5.0/24"
  display_name               = "fss_subnet_private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.my_private_rt.id
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "fsspriv"
}

