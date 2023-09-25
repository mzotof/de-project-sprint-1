create or replace view analysis.orders as
with all_statuses as (
    select
        o.order_id,
        o.order_ts,
        o.user_id,
        o.bonus_payment,
        o.payment,
        o.cost,
        o.bonus_grant,
        l.status_id,
        row_number() over (partition by o.order_id order by l.dttm desc nulls last) as rn
    from production.orders as o
    left join production.orderstatuslog as l using (order_id)
)
select
    order_id,
    order_ts,
    user_id,
    bonus_payment,
    payment,
    cost,
    bonus_grant,
    s.key as status
from all_statuses a
left join production.orderstatuses as s
on a.status_id = s.id
where a.rn = 1;
