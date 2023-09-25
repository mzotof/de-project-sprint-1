truncate table analysis.tmp_rfm_monetary_value;
insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
with order_sum_cost as (
    select user_id, sum(cost) as sum_cost
    from analysis.orders
    where upper(status) = 'CLOSED'
        and extract(year from order_ts) >= 2022
    group by user_id
)
select
    user_id,
    ((row_number() over (order by sum_cost) - 1) * 5 / (select count(1) from order_sum_cost)) + 1 as monetary_value
from order_sum_cost;
