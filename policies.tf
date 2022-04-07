## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "functions_dynamic_group" {
    provider = oci.homeregion
    compartment_id = var.tenancy_ocid
    description = "Group of functions"
    matching_rule = "ALL {resource.type='fnfunc' ,resource.compartment.id='${var.compartment_ocid}'}"
    name = "functions"

}

resource "oci_identity_policy" "sch_policies" {
  depends_on = [
    oci_sch_service_connector.sch
  ]
  provider       = oci.homeregion
  compartment_id = var.compartment_ocid
  name           = "Sch_policies"
  description    = "Policy to provide access to service connector hub to write in object storage bucket, read streams and call functions"
  statements     = [
    
    "allow any-user to use stream-push in compartment id ${var.compartment_ocid} where all { request.principal.type = 'serviceconnector', target.stream.id = '${oci_streaming_stream.stream_out.id}', request.principal.compartment.id = '${var.compartment_ocid}' }",
    "allow any-user to {STREAM_READ, STREAM_CONSUME} in compartment id ${var.compartment_ocid} where all { request.principal.type = 'serviceconnector', target.stream.id = '${oci_streaming_stream.stream_in.id}', request.principal.compartment.id = '${var.compartment_ocid}' } ",
    "allow any-user to use fn-function in compartment id ${var.compartment_ocid} where all { request.principal.type = 'serviceconnector', request.principal.compartment.id = '${var.compartment_ocid}' }" ,
    "allow any-user to use fn-invocation in compartment id ${var.compartment_ocid} where all { request.principal.type = 'serviceconnector', request.principal.compartment.id = '${var.compartment_ocid}' }"
    # "allow dynamic-group functions to use ai-service-language-family in tenancy"
  ]
}
