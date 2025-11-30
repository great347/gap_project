{{ config(alias='br_transaction',
    materialized='incremental',
    unique_key ='transaction_id',
    partition_by={
        "field": "transaction_update_date",
        "data_type": "timestamp",
        "granularity": "day"
    },
    
    cluster_by=["transaction_id", "transaction_update_date"]


) }}

with transaction_raw as (
SELECT 
    transaction_id,
    consumer_id,
    CAST(transaction_created_at as TIMESTAMP) as transaction_created_at,
    CAST(transaction_update_date AS TIMESTAMP) as transaction_update_date,
    transaction_type,
    transaction_payment_value
FROM 
    {{ source('dbt_dataset', 'transaction') }}
)
select 
    transaction_id,
    consumer_id,
    transaction_created_at,
    transaction_update_date,
    transaction_type,
    transaction_payment_value
from transaction_raw

{% if is_incremental() %}
   where transaction_update_date > (
     select coalesce(max(transaction_update_date), '2001-01-01') from {{ this }}
   )
{% endif %}