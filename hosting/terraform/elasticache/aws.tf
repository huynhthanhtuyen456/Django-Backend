variable "config" {
  type = "map"
}

provider "aws" {
  region = "${var.config["region"]}"
  profile = "${var.config["profile"]}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name                                  = "${var.config["domain"]}"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "redis-cluster-prod"
  replication_group_description = "Redis Cluster"
  node_type                     = "cache.t2.small"
  port                          = 6379
  parameter_group_name          = "default.redis5.0.cluster.on"
  automatic_failover_enabled    = true

  cluster_mode {
    replicas_per_node_group = 2
    num_node_groups         = 1
  }
}
