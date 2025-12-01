{{- config(alias='top_customers'
, materialized ='view'
,enabled = True
)
-}}


with count_customer_transactions AS (
    select
        customer_id,
        COUNT(transaction_id) as transaction_count
    from
        {{ref('fact_transactions')}}
    group by customer_id
)
,

percentile_calculation as (
    select
        APPROX_QUANTILES(transaction_count, 100)[OFFSET(90)] as percentile_threshold

    from
        count_customer_transactions
)

select 
    cct.customer_id,
    cct.transaction_count
from 
    count_customer_transactions AS cct,
    percentile_calculation AS pc
where 
    cct.transaction_count >= pc.percentile_threshold
order by
    cct.transaction_count desc