create or replace view analysis.users as
select id, name, login
from production.users;

create or replace view analysis.orderitems as
select id, product_id, order_id, name, price, discount, quantity
from production.orderitems;

create or replace view analysis.orderstatuses as
select id, key
from production.orderstatuses;

create or replace view analysis.products as
select id, name, price
from production.products;

create or replace view analysis.orders as
select
    o.order_id,
    o.order_ts,
    o.user_id,
    o.bonus_payment,
    o.payment,
    o.cost,
    o.bonus_grant,
    s.key as status
from production.orders as o
left join production.orderstatuses as s
on o.status = s.id;
