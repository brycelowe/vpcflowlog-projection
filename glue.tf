resource "aws_glue_catalog_database" "logs" {
  name = "aws_logs"
}

# table definition pulled from https://docs.aws.amazon.com/athena/latest/ug/vpc-flow-logs.html
resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  for_each = data.aws_s3_bucket.flowlogs

  name          = "vpc_flow_logs_${each.key}"
  database_name = aws_glue_catalog_database.logs.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE"
    "skip.header.line.count" = "1"

    "projection.enabled" = "true",
    # aws-account-id
    "projection.aws-account-id.type"   = "enum"
    "projection.aws-account-id.values" = data.aws_caller_identity.current.account_id
    # aws-servicew
    "projection.aws-service.type"   = "enum"
    "projection.aws-service.values" = "vpcflowlogs"
    # aws-region
    "projection.aws-region.type"   = "enum"
    "projection.aws-region.values" = data.aws_region.current.name
    # year
    "projection.year.type"   = "enum",
    "projection.year.values" = formatdate("YYYY", timestamp()),
    # month (note: integers don't seem to keep their zero padding)
    "projection.month.type"   = "enum",
    "projection.month.values" = "01,02,03,04,05,06,07,08,09,10,11,12"
    # day
    "projection.day.type"   = "enum",
    "projection.day.values" = "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31",
    # hour
    "projection.hour.type"   = "enum",
    "projection.hour.values" = "00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23",

    "storage.location.template" = "s3://${each.value.id}/AWSLogs/$${aws-account-id}/$${aws-service}/$${aws-region}/$${year}/$${month}/$${day}/$${hour}/"
  }

  partition_keys {
    name = "aws-account-id"
    type = "string"
  }

  partition_keys {
    name = "aws-service"
    type = "string"
  }

  partition_keys {
    name = "aws-region"
    type = "string"
  }

  partition_keys {
    name = "year"
    type = "string"
  }

  partition_keys {
    name = "month"
    type = "string"
  }

  partition_keys {
    name = "day"
    type = "string"
  }

  partition_keys {
    name = "hour"
    type = "string"
  }


  storage_descriptor {
    location      = "s3://${each.value.id}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "version"
      type = "int"
    }

    columns {
      name = "account_id"
      type = "string"
    }

    columns {
      name = "interface_id"
      type = "string"
    }

    columns {
      name = "srcaddr"
      type = "string"
    }

    columns {
      name = "dstaddr"
      type = "string"
    }

    columns {
      name = "srcport"
      type = "int"
    }

    columns {
      name = "dstport"
      type = "int"
    }

    columns {
      name = "protocol"
      type = "bigint"
    }

    columns {
      name = "packets"
      type = "bigint"
    }

    columns {
      name = "bytes"
      type = "bigint"
    }

    columns {
      name = "start"
      type = "bigint"
    }

    columns {
      name = "end"
      type = "bigint"
    }

    columns {
      name = "action"
      type = "string"
    }

    columns {
      name = "log_status"
      type = "string"
    }

    columns {
      name = "vpc_id"
      type = "string"
    }

    columns {
      name = "subnet_id"
      type = "string"
    }

    columns {
      name = "instance_id"
      type = "string"
    }

    columns {
      name = "tcp_flags"
      type = "int"
    }

    columns {
      name = "type"
      type = "string"
    }

    columns {
      name = "pkt_srcaddr"
      type = "string"
    }

    columns {
      name = "pkt_dstaddr"
      type = "string"
    }

    columns {
      name = "region"
      type = "string"
    }

    columns {
      name = "az_id"
      type = "string"
    }

    columns {
      name = "sublocation_type"
      type = "string"
    }

    columns {
      name = "sublocation_id"
      type = "string"
    }

    columns {
      name = "pkt_src_aws_service"
      type = "string"
    }

    columns {
      name = "pkt_dst_aws_service"
      type = "string"
    }

    columns {
      name = "flow_direction"
      type = "string"
    }

    columns {
      name = "traffic_path"
      type = "int"
    }
  }
}
