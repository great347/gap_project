{{- config(alias='fact_transaction'
, materialized ='table'
, unique_key='transaction_skey')
-}}



select
    ta.transaction_skey,
    ta.transaction_id,
    ta.customer_id,
    ta.transaction_type,
    ta.transaction_date,
    ta.transaction_update_date,
    ta.transaction_payment

from
    {{ ref('slv_transactions') }} ta
left join {{ ref('slv_customers') }} sc 
        on ta.customer_id = sc.customer_id
