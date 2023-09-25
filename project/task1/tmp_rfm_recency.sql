truncate table analysis.tmp_rfm_recency;
insert into analysis.tmp_rfm_recency (user_id, recency)
with last_order_ts as (
    select user_id, max(order_ts) ts
    from analysis.orders
    where upper(status) = 'CLOSED'
        and extract(year from order_ts) >= 2022
    group by user_id
)
select
    user_id,
    ((row_number() over (order by ts nulls first) - 1) * 5 / (select count(1) from last_order_ts)) + 1 as recency
from last_order_ts;
