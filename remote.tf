## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "kafka_connector_config" {

  depends_on = [oci_core_instance.compute_instance, oci_streaming_connect_harness.connect_harness, oci_streaming_stream_pool.stream_pool]

  template = file("./config/connect-distributed.properties")

  vars = {
    REGION               = var.region
    CONNECT_HARNESS_OCID = oci_streaming_connect_harness.connect_harness.id
    TENANCY_NAME         = data.oci_identity_tenancy.current_user_tenancy.name
    USER_NAME            = data.oci_identity_user.current_user.name
    AUTH_CODE            = oci_identity_auth_token.auth_token.token
    STREAM_POOL          = oci_streaming_stream_pool.stream_pool.id
  }
}

data "template_file" "twitter_connector_config" {

  depends_on = [oci_core_instance.compute_instance, oci_streaming_connect_harness.connect_harness, oci_streaming_stream_pool.stream_pool]

  template = file("./config/twitter_connector.json")

  vars = {
    twitter_oauth_accessToken       = var.twitter_oauth_accessToken
    twitter_oauth_accessTokenSecret = var.twitter_oauth_accessTokenSecret
    twitter_oauth_consumerKey       = var.twitter_oauth_consumerKey
    twitter_oauth_consumerSecret    = var.twitter_oauth_consumerSecret
    topic_name                      = var.source_stream_name
    filter                          = var.twitter_filter
  }
}

resource "null_resource" "run_scripts" {

  depends_on = [oci_core_instance.compute_instance, oci_streaming_stream_pool.stream_pool, oci_streaming_connect_harness.connect_harness]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance.public_ip
      private_key = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.private_key_pem : file(var.private_ssh_key_path)
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.kafka_connector_config.rendered
    destination = "/home/opc/connect-distributed.properties"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance.public_ip
      private_key = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.private_key_pem : file(var.private_ssh_key_path)
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.twitter_connector_config.rendered
    destination = "/home/opc/twitter_connector.json"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance.public_ip
      private_key = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.private_key_pem : file(var.private_ssh_key_path)
      agent       = false
      timeout     = "10m"
    }

    inline = [
      "sudo yum install java-1.8.0-openjdk.x86_64 -y",
      "wget https://archive.apache.org/dist/kafka/2.5.1/kafka_2.12-2.5.1.tgz",
      "tar -xvf kafka_2.12-2.5.1.tgz",
      "mv kafka_2.12-2.5.1 kafka",
      "wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/jcustenborder/kafka-connect-twitter/versions/0.2.32/jcustenborder-kafka-connect-twitter-0.2.32.zip",
      "unzip jcustenborder-kafka-connect-twitter-0.2.32.zip",
      "cp jcustenborder-kafka-connect-twitter-0.2.32/lib/*.jar kafka/libs/",
      "sleep 5"
    ]
  }
}



