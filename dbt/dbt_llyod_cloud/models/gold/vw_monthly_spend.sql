{{- config(alias='monthly_spending'
, materialized ='view'
)
-}}


select 
    FORMAT_TIMESTAMP('%Y-%m', transaction_date) as spend_month,
    dc.customer_id,
    SUM(ft.transaction_payment) as total_spend,
    AVG(ft.transaction_payment) as average_spend
from 
    {{ ref('fact_transactions') }} ft
inner join {{ ref('dim_customers') }}  dc 
    on ft.customer_id = dc.customer_id  
group by spend_month, dc.customer_id
order by spend_month desc