provider "b2" {
  application_key_id = local.secrets.api-key.b2.id
  application_key    = local.secrets.api-key.b2.key
}

resource "b2_bucket" "chest" {
  bucket_name = "mlatus-chest"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_uploading_to_hiding = null
    days_from_hiding_to_deleting  = 1
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "b2_application_key" "chest" {
  key_name  = "mlatus-chest"
  bucket_id = b2_bucket.chest.id
  capabilities = [
    "deleteFiles",
    "listAllBucketNames",
    "listBuckets",
    "listFiles",
    "readBucketEncryption",
    "readBuckets",
    "readFiles",
    "shareFiles",
    "writeBucketEncryption",
    "writeFiles"
  ]

  lifecycle {
    prevent_destroy = true
  }
}
