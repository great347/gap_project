#### Data Platform Migration Prototype (GCP)
The proof of concept project a modern data pipeline on Google Cloud Platform for ingesting, processing, and analyzing customer transaction data.


##### Architecture Overview
A scalable medallion architecture is employed for the design of the data infrastructure.

Ingestion: data lands in raw layer (CSV files).
Processing: The data is moved to the raw layer in the Bigquery using Python Apache Beam pipeline (Dataflow).
Transformation: dbt models are used to build curated Gold layer tables with optimized partitioning and clustering.
Orchestration: Cloud Composer manages the workflow execution.


##### Setup Instructions
###### Prerequisites
gcloud, 
terraform, 
git, 
python3 installed locally.
pip install Faker apache-beam[gcp]

###### GCP Permissions
The user account or CI/CD service account running Terraform and the pipelines needs the following roles:
roles/editor 
roles/storage.admin
roles/bigquery.admin
roles/dataflow.admin



###### Terraform Deployment
Navigate to the gcp_project/terraform directory.
Update variables.tf and terraform.tfvars with your project details.
run the following command:
terraform init
terraform plan
terraform apply

###### Running the Data Pipeline

Upload the data to the GCS bucket.
Launch the Dataflow pipeline using the Python script 

###### Running dbt Transformations
Navigate to the dbt/project directory.
Update profiles.yml to point to your BigQuery project (using ADC authentication).
Run the models: dbt build

###### Assumptions
Source CSV files are comma-delimited and use a header row.
The system uses Workload Identity Federation or Application Default Credentials (ADC) for secure authentication.
BigQuery schema names used in UDFs and dbt models are consistent (e.g., snake_case).




