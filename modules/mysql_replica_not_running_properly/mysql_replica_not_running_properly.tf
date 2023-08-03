resource "shoreline_notebook" "mysql_replica_not_running_properly" {
  name       = "mysql_replica_not_running_properly"
  data       = file("${path.module}/data/mysql_replica_not_running_properly.json")
  depends_on = [shoreline_action.invoke_replication_check,shoreline_action.invoke_check_replica_status,shoreline_action.invoke_replicate_schema_changes,shoreline_action.invoke_check_replica_resources]
}

resource "shoreline_file" "replication_check" {
  name             = "replication_check"
  input_file       = "${path.module}/data/replication_check.sh"
  md5              = filemd5("${path.module}/data/replication_check.sh")
  description      = "Network issues preventing replication between primary and replica servers."
  destination_path = "/agent/scripts/replication_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_replica_status" {
  name             = "check_replica_status"
  input_file       = "${path.module}/data/check_replica_status.sh"
  md5              = filemd5("${path.module}/data/check_replica_status.sh")
  description      = "Check if replica_IO_running and replica_SQL_running are running"
  destination_path = "/agent/scripts/check_replica_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "replicate_schema_changes" {
  name             = "replicate_schema_changes"
  input_file       = "${path.module}/data/replicate_schema_changes.sh"
  md5              = filemd5("${path.module}/data/replicate_schema_changes.sh")
  description      = "Determine whether there are any database schema changes that have been made on the master MySQL server that have not been replicated on the replica server."
  destination_path = "/agent/scripts/replicate_schema_changes.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_replica_resources" {
  name             = "check_replica_resources"
  input_file       = "${path.module}/data/check_replica_resources.sh"
  md5              = filemd5("${path.module}/data/check_replica_resources.sh")
  description      = "Ensure that the replica is not overloaded and has sufficient resources to perform the replication task."
  destination_path = "/agent/scripts/check_replica_resources.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_replication_check" {
  name        = "invoke_replication_check"
  description = "Network issues preventing replication between primary and replica servers."
  command     = "`chmod +x /agent/scripts/replication_check.sh && /agent/scripts/replication_check.sh`"
  params      = []
  file_deps   = ["replication_check"]
  enabled     = true
  depends_on  = [shoreline_file.replication_check]
}

resource "shoreline_action" "invoke_check_replica_status" {
  name        = "invoke_check_replica_status"
  description = "Check if replica_IO_running and replica_SQL_running are running"
  command     = "`chmod +x /agent/scripts/check_replica_status.sh && /agent/scripts/check_replica_status.sh`"
  params      = []
  file_deps   = ["check_replica_status"]
  enabled     = true
  depends_on  = [shoreline_file.check_replica_status]
}

resource "shoreline_action" "invoke_replicate_schema_changes" {
  name        = "invoke_replicate_schema_changes"
  description = "Determine whether there are any database schema changes that have been made on the master MySQL server that have not been replicated on the replica server."
  command     = "`chmod +x /agent/scripts/replicate_schema_changes.sh && /agent/scripts/replicate_schema_changes.sh`"
  params      = ["MASTER_DB_PASSWORD","MASTER_DB_USERNAME","MASTER_DB_HOST","REPLICA_DB_HOST"]
  file_deps   = ["replicate_schema_changes"]
  enabled     = true
  depends_on  = [shoreline_file.replicate_schema_changes]
}

resource "shoreline_action" "invoke_check_replica_resources" {
  name        = "invoke_check_replica_resources"
  description = "Ensure that the replica is not overloaded and has sufficient resources to perform the replication task."
  command     = "`chmod +x /agent/scripts/check_replica_resources.sh && /agent/scripts/check_replica_resources.sh`"
  params      = ["MIN_FREE_SPACE","MAX_LOAD_AVERAGE"]
  file_deps   = ["check_replica_resources"]
  enabled     = true
  depends_on  = [shoreline_file.check_replica_resources]
}

