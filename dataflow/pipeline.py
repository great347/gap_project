import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.gcsfilesystem import GCSFileSystem
import re

# ---------- Transform functions (Corrected Transaction transform logic) ----------
class TransformCustomer(beam.DoFn):
    def process(self, line):
        values = line.split(",")
        # Assuming BQ schema is snake_case and matches these keys exactly
        yield {
            "customer_id": int(values[0]),
            "full_name": values[1],
            "post_code": values[2],
            "city": values[3],
            "region": values[4],
            "last_update_date": values[5].strip(), # remove trailing whitespace
        }

class TransformTransaction(beam.DoFn):
    def process(self, line):
        values = line.split(",")
        # Assuming BQ schema is snake_case and matches these keys exactly
        # Note: You were using values[4] twice for type and value, assuming value[5] is payment value
        yield {
            "transaction_id": int(values[0]),
            "customer_id": int(values[1]),
            "transaction_created_at": values[2].strip(),
            "transaction_update_date": values[3].strip(),
            "transaction_type": values[4].strip(),
            "transaction_payment_value": float(values[5]), # Assuming index 5 is the value
        }

# ---------- Determine type from filename/path ----------
def detect_file_type(file_path):
    """Detects the file type based on keywords present in the path or filename."""
    path_lower = file_path.lower()
    if "customer" in path_lower and "final" in path_lower:
        return "customer_final"
    elif "api" in path_lower and "transaction" in path_lower:
        return "api_transaction"
    else:
        return None

# ---------- Main Pipeline ----------
def run():
    opts = PipelineOptions(save_main_session=True, streaming=False)
    
    # Use a wildcard (**) to read recursively from ALL subfolders in the bucket
    input_pattern = "gs://your-bucket/**/*.csv"
    
    # List all files matching the recursive pattern
    fs = GCSFileSystem(PipelineOptions())
    # Note: fs.match returns a list of FileMetadata lists, so we flatten it
    all_files_metadata = [metadata for pattern_match in fs.match([input_pattern]) for metadata in pattern_match.metadata_list]
    file_paths = [f.path for f in all_files_metadata]
    
    # You MUST define your actual BigQuery project/dataset/table names and schemas here
    BQ_DATASET = "dbt_dataset"
    CUSTOMER_SCHEMA = "customer_schema.json" # Provide the path to your local schema file
    TRANSACTION_SCHEMA = "transaction_schema.json" # Provide the path to your local schema file


    with beam.Pipeline(options=opts) as p:
        for file_path in file_paths:
            file_type = detect_file_type(file_path)
            
            # Note: The logic below creates N independent sub-pipelines for N files.
            # This works but can be less efficient than reading all files at once and using Pardo.
            # For simplicity matching your original structure, we keep it this way.

            if file_type == "customer_final":
                print(f"Processing Customer file: {file_path}")
                (
                    p
                    | f"Read Customer {file_path}" >> beam.io.ReadFromText(file_path, skip_header_lines=1)
                    | f"Transform Customer {file_path}" >> beam.ParDo(TransformCustomer())
                    | f"Write Customer BQ {file_path}" >> beam.io.WriteToBigQuery(
                        table=f"{BQ_DATASET}.customers",
                        schema=CUSTOMER_SCHEMA,
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
                        table=f"{BQ_DATASET}.transactions",
                        schema=TRANSACTION_SCHEMA,
                        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
                    )
                )
            else:
                print(f"Skipping unknown file: {file_path}")

if __name__ == "__main__":
    run()
