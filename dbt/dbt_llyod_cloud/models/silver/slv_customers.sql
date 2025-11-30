{{- config(alias='slv_customer'
, materialized ='table'
, unique_key='customer_skey')
-}}


with customer_bronze_source as (
    select
        customer_id,
        full_name,
        post_code,
        city,
        region,
        CAST(last_update_date AS TIMESTAMP) as last_update_date
    from 
        {{ ref('br_customers') }}
)
,

cleaned_customer_names as (
    select
        *,
        -- removes titles in the customer_fullname
        ( {{clean_fullname('full_name')}} ) as cleaned_fullname_derived
    from
        customer_bronze_source
)
,
split_customer_irst_and_last_names as (
    select
        *,
        REGEXP_EXTRACT(cleaned_fullname_derived, r'^(\S+)') as first_name,
        REGEXP_EXTRACT(cleaned_fullname_derived, r'.* (\S+)$') as last_name
    from
        cleaned_customer_names
)
,

customer_silver as (
    select
    
        customer_id,
        full_name as original_fullname,
        ( {{mask_postcode('post_code')}} ) as customer_postcode,
        city,
        region,
        last_update_date,

        -- Select derived names
        first_name,
        last_name,

        -- Apply the hashing macro to the new first_name and last_name columns
         ( {{hash_column_name('first_name')}} ) as hashed_first_name,
         ( {{hash_column_name('last_name')}} ) as hashed_last_name,
    

    from split_customer_irst_and_last_names
    
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'last_update_date']) }} AS customer_skey,
    customer_id,
    hashed_first_name as customer_firstname,
    hashed_last_name as customer_lastname,
    customer_postcode,
    city,
    region,
    DATE(last_update_date) as last_update_date

from
    customer_silver