{{ config(alias='br_customer',
    materialized='incremental',
    unique_key ='customer_id',
    partition_by={
        "field": "last_update_date",
        "data_type": "timestamp",
        "granularity": "day"
    },
    
    cluster_by=["customer_id", "region", "city"]


) }}

with customer_raw as (
select
    customer_id,
    full_name,
    post_code,
    city,
    region,
    CAST(last_update_date as TIMESTAMP) as last_update_date,

from  {{ source('dbt_dataset', 'customer') }}
)

select
    customer_id,
    full_name,
    post_code,
    city,
    region,
    last_update_date
from customer_raw 
{% if is_incremental() %}
   where last_update_date > (
     select coalesce(max(last_update_date), '2001-01-01') from {{ this }}
   )
{% endif %}
