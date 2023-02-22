
##################################################
################## Big Query  ####################
##################################################



resource "google_bigquery_dataset" "dataset" {
  project       = var.project_id
  dataset_id    = "raw"
  friendly_name = "aw"
  description   = "data set"
  location      = "EU"


  labels = {
    env = ""
  }
}

resource "google_bigquery_table" "raw_sheet" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "raw-sheet"



  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema              = <<EOF
[
    {
        "name": "date",
        "type": "DATE",
        "mode": "REQUIRED"
      },
      {
        "name": "region",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "sector_id",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "brand_id",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "metric",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "sector_label",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The descriptive label for the sector_id"
      },
      {
        "name": "brand_label",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The descriptive label for the brand_id"
      },
      {
        "name": "ingest_datetime",
        "type": "DATETIME",
        "mode": "REQUIRED",
        "description": "The datetime this record was actually fetched / written to BQ"
      },
      {
        "name": "query",
        "type": "STRING",
        "mode": "REQUIRED",
        "description": "The sub-query that generated this record"
      },
      {
        "name": "volume",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "score",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "positives",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "negatives",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "neutrals",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "positives_neutrals",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "negatives_neutrals",
        "type": "STRING",
        "mode": "NULLABLE"
      }
  ]    
EOF
  deletion_protection = false # important
}



# }


locals {
  project = var.project_id
}


resource "google_bigquery_table" "query_table" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "query-view"


  view {
    use_legacy_sql = false
    query          = <<-EOF
  SELECT * except (rank)
  FROM (
    SELECT 
      *,
      rank() over (partition by tbl.date, tbl.region, tbl.sector_id, tbl.brand_id, tbl.metric, tbl.query order by tbl.ingest_datetime desc) as rank
    FROM `${local.project}.raw.raw-sheet` as tbl
  ) 
  WHERE 
    rank = 1 and score != ""
    EOF
  }

  deletion_protection = false # important
  depends_on = [
    google_bigquery_dataset.dataset,
    google_bigquery_table.raw_sheet
  ]
}
