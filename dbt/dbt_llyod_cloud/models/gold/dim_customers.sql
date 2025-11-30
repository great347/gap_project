{{- config(alias='dim_customer'
, materialized ='table'
, unique_key='customer_skey')
-}}



select
    customer_skey,
    customer_id,
    customer_firstname,
    customer_lastname,
    customer_postcode,
    city,
    region,
    last_update_date

from
    {{ ref('slv_customers')}}