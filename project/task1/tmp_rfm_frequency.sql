truncate table analysis.tmp_rfm_frequency;
insert into analysis.tmp_rfm_frequency (user_id, frequency)
with order_cnt as (
    select user_id, count(1) as cnt
    from analysis.orders
    where upper(status) = 'CLOSED'
        and extract(year from order_ts) >= 2022
    group by user_id
)
select
    user_id,
    ((row_number() over (order by cnt) - 1) * 5 / (select count(1) from order_cnt)) + 1 as frequency
from order_cnt;
