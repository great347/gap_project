### Data Platform Migration Prototype (GCP)
The project prototyped a modern data pipeline that is leveraging google cloud platform to ingest, process, and
expose customer transaction data to support business reporting


### Architecture Overview
A scalable medallion architecture is employed for the design of the data infrastructure.

* Ingestion: data lands in raw layer (CSV files).

* Processing: The data is moved to the raw layer in the Bigquery using Python Apache Beam pipeline (Dataflow).

* Transformation: dbt is used to load the data into the bronze layer; clean, transformed the data in the silver layer and to build curated Gold layer tables and view with optimized partitioning and clustering.

* Orchestration: Cloud Composer manages the workflow execution.


### Setup Instructions
#### Prerequisites
* gcloud, 
* terraform, 
* git, 
* python3 installed locally.
* pip install Faker apache-beam[gcp]

#### GCP Permissions
The user account or CI/CD service account running Terraform and the pipelines needs the following roles:
* roles/editor 
* roles/storage.admin
* roles/bigquery.admin
* roles/dataflow.admin



#### Terraform Deployment
Navigate to the gcp_project/terraform directory.
* Update variables.tf and terraform.tfvars with your project details.
* run the following command:
  * terraform init
  * terraform plan
  * terraform apply

#### Running the Data Pipeline

* Upload the data to the GCS bucket.
* Launch the Dataflow pipeline using the Python script 

#### Running dbt Transformations
* Navigate to the dbt/project directory.
* Update profiles.yml to point to your BigQuery project (using ADC authentication).
* Run the models: dbt build

#### Assumptions
* Source CSV files are comma-delimited and use a header row.
* The customer and transaction file aee coming from two seperato sources and in are lood seperate folder in the gcs bucket
* The system uses Workload Identity Federation or Application Default Credentials (ADC) for secure authentication.
* BigQuery schema names used in UDFs and dbt models are consistent (e.g., snake_case).
