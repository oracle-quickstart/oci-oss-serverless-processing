## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_sch_service_connector" "sch" {
  compartment_id = var.compartment_ocid
  display_name   = var.sch_connector_name
  state          = "ACTIVE"

  source {
    kind      = "streaming"
    stream_id = oci_streaming_stream.stream_in.id
  }

  target {
    kind      = "streaming"
    stream_id = oci_streaming_stream.stream_out.id
  }

  tasks {
    kind              = "function"
    function_id       = oci_functions_function.function.id
    batch_size_in_kbs = var.service_connector_tasks_batch_size_in_kbs
    batch_time_in_sec = var.service_connector_tasks_batch_time_in_sec
  }

}

