## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_functions_application" "fn_application" {
    compartment_id = var.compartment_ocid
    display_name = "cloud-sch-demo-app"
    subnet_ids = [oci_core_subnet.kafkaConnectSubnet.id]
    
}

resource "oci_functions_function" "function" {
    depends_on = [null_resource.function_Push2OCIR]
    application_id = oci_functions_application.fn_application.id
    display_name = "cloud-ai-sentiments-fn"
    image = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/cloud-ai-sentiments-fn:0.0.1"
    memory_in_mbs = "256" 
    config = { 
      "REGION" : "${var.region}"
    }
}

resource "oci_artifacts_container_repository" "sch_fn_container_repository" {
    #Required
    compartment_id = var.compartment_ocid
    display_name = "${var.ocir_repo_name}/cloud-ai-sentiments-fn"

}

