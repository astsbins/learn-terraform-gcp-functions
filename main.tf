terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = "australia-southeast1"
  zone    = "australia-southeast1-a"
}
# create bucket
resource "google_storage_bucket" "bucket" {
  name = "test-bucket-123terra"
}
 

# upload code
resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./python_code.zip"
}

# create function
resource "google_cloudfunctions_function" "function" {
  name             = "test_function123terra"
  description      = "My function"
  runtime          = "python39"
  ingress_settings = "ALLOW_ALL"
  service_account_email = "terrarform-service-account@my-terraform-project-325905.iam.gserviceaccount.com"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "test_function"
}


# makes accessible to everyone
resource "google_cloudfunctions_function_iam_binding" "binding" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.invoker"
  members = [
    "allUsers",
  ]
}

#convert to module
# use existing service account
# monitoring is enabled. When a monitoring even is triggered from policies, when ever the threshold is breeched, a incident is generated
# has pubsub notification channel -> data pulled by splunk
# arugements, 
# call service accounts -> pull down information about it. Have ability service to use existing service account from environment
# check if code can be grabbed from github
