{{- config(alias='slv_transaction'
, materialized ='table'
, unique_key='transaction_skey')
-}}


select 
    {{ dbt_utils.generate_surrogate_key(['transaction_id', 'transaction_update_date']) }} AS transaction_skey,
    transaction_id,
    consumer_id as customer_id,
    transaction_type,
    DATE(transaction_created_at) as transaction_date,
    DATE(transaction_update_date) as transaction_update_date,
    transaction_payment_value as transaction_payment,
from {{ ref('br_transactions') }}