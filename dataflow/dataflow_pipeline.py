import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, GoogleCloudOptions, StandardOptions



class TransformCustomer(beam.DoFn):
    def process(self, line):
        values = line.split(",")

        yield {
            "customer_id": int(values[0]),
            "full_name": values[1],
            "post_code": values[2],
            "city": values[3],
            "region": values[4],
            "last_update_date": values[5].strip(), 
        }

class TransformTransaction(beam.DoFn):
    def process(self, line):
        values = line.split(",")
      
        yield {
            "transaction_id": int(values[0]),
            "consumer_id": int(values[1]),
            "transaction_created_at": values[2].strip(),
            "transaction_update_date": values[3].strip(),
            "transaction_type": values[4].strip(),
            "transaction_payment_value": float(values[5]),
        }

# selecting file tyoe 
def detect_file_type(file_path):
    if "customers" in file_path:
        return "customers_final"
    elif "transaction" in file_path:
        return "api_transaction"
    else:
        return "unknown"

# dataflow run function
def run():
    options = PipelineOptions()
    google_cloud_options = options.view_as(GoogleCloudOptions)
    google_cloud_options.project = BQ_PROJECT
    google_cloud_options.region = 'us-central1'
    google_cloud_options.temp_location = 'gs://dataflow-staging-us-central1-226403353486/temp/'
    google_cloud_options.staging_location = 'ggs://dataflow-staging-us-central1-226403353486/staging/'

    google_cloud_options.service_account_email = 'dbt-service-account@int-dev-001.iam.gserviceaccount.com'

   
    options.view_as(StandardOptions).runner = 'DataflowRunner'

    file_paths = ["gs://llyod_bucket1234/sqlserver/customers_final.csv", "gs://llyod_bucket1234/api/api_transaction.csv"] 

    with beam.Pipeline(options=options) as p:
        for file_path in file_paths:
            file_type = detect_file_type(file_path)

            if file_type == "customers_final":
                print(f"Processing Customer file: {file_path}")
                (
                    p
                    | f"Read Customer {file_path}" >> beam.io.ReadFromText(file_path, skip_header_lines=1)
                    | f"Transform Customer {file_path}" >> beam.ParDo(TransformCustomer())
                    | f"Write Customer BQ {file_path}" >> beam.io.WriteToBigQuery(
                        table=f"{BQ_PROJECT}:{BQ_DATASET}.customer",
                        schema=CUSTOMER_SCHEMA_JSON,
                        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
                    )
                )
            elif file_type == "api_transaction":
                print(f"Processing Transaction file: {file_path}")
                (
                    p
                    | f"Read Transaction {file_path}" >> beam.io.ReadFromText(file_path, skip_header_lines=1)
                    | f"Transform Transaction {file_path}" >> beam.ParDo(TransformTransaction())
                    | f"Write Transaction BQ {file_path}" >> beam.io.WriteToBigQuery(
                        table=f"{BQ_PROJECT}:{BQ_DATASET}.transaction",
                        schema=TRANSACTION_SCHEMA_JSON,
                        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
                    )
                )
            else:
                print(f"Skipping unknown file: {file_path}")

if __name__ == "__main__":
    BQ_PROJECT = "int-dev-001" 
    BQ_DATASET = "dbt_dataset" 
    CUSTOMER_SCHEMA_JSON = {
        "fields": [
            { "name": "customer_id", "type": "INTEGER" , "mode": "REQUIRED"}, 
            { "name": "full_name", "type": "STRING", "mode": "REQUIRED"}, 
            { "name": "post_code", "type": "STRING" ,"mode": "REQUIRED"}, 
            { "name": "city", "type": "STRING" , "mode": "REQUIRED"}, 
            { "name": "region", "type": "STRING" ,"mode": "REQUIRED"},
            { "name": "last_update_date", "type": "STRING" ,"mode": "REQUIRED"}
        ] 
    }
    TRANSACTION_SCHEMA_JSON = {
        "fields": [ 
            { "name": "transaction_id", "type": "INTEGER", "mode": "REQUIRED"}, 
            { "name": "consumer_id", "type": "INTEGER" , "mode": "REQUIRED"}, 
            { "name": "transaction_created_at", "type": "STRING" ,"mode": "REQUIRED"}, 
            { "name": "transaction_update_date", "type": "STRING" ,"mode": "REQUIRED"}, 
            { "name": "transaction_type", "type": "STRING" ,"mode": "REQUIRED"},
            { "name": "transaction_payment_value", "type": "FLOAT","mode": "REQUIRED" }
    ] 
    }
    run()
