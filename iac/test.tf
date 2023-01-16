
#   resource "google_bigquery_table" "yougov_test_01_table" {
#   project = var.project_id
#   dataset_id = google_bigquery_dataset.yougov_dataset.dataset_id
#   table_id   = "yougov-test-01-view"


# view {
#     use_legacy_sql = false
#     query =  <<-EOF


#   SELECT * except (rank)
#   FROM (
#     SELECT 
#       *,
#       rank() over (partition by tbl.date, tbl.region, tbl.sector_id, tbl.brand_id, tbl.metric, tbl.query order by tbl.ingest_datetime desc) as rank
#      FROM `${local.project}.yougov_raw.yougov-raw-sheet` as tbl
#   ) 
#   WHERE 
#     rank = 1 and score != ""
#     EOF
#     }

# deletion_protection = false # important
# depends_on = [
#   google_bigquery_dataset.yougov_dataset
# ]
# }
