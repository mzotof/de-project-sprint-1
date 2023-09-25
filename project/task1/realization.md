# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

-----------

Необходимо разработать витрину analysis.dm_rfm_segments для RFM-классификации. Для анализа нужно отобрать только успешно выполненные заказы (статус заказа = Closed).

Состав полей:
- user_id - id пользователя
- recency - сколько времени прошло с момента последнего заказа (число от 1 до 5)
- frequency - количество заказов (число от 1 до 5)
- monetary_value - сумма затрат клиента (число от 1 до 5)

В витрине нужны данные с начала 2022 года.

Режим загрузки - полный срез, обновления не нужны.

## 1.2. Изучите структуру исходных данных.

-----------

В схеме production есть следующие таблицы:
- orderitems - состав заказов
- orders - заказы с их актуальными статусами
- orderstatuses - словарь с расшифровками статусов заказов
- orderstatuslog - история изменения статусов заказов
- products - товары компании
- users - пользователи

Для построения RFM-классификации достаточно таблицы production.orders, так как анализируется поведение клиентов по их заказам. 
В витрине будут использоваться следующие поля таблицы production.orders:
- order_ts для фильтрации заказов 2022 года и позже
- user_id для агрегирования информации по одному пользователю
- cost (или payment - необходимо уточнить у заказчика какое поле использовать, зависит от того нужно ли ему считать учитывая оплату бонусами или нет) для суммирования стоимости заказов
- status для определения статуса заказа, но тут необходим джойн на production.orderstatuses для определения какой код статуса Closed.

Также для 2 части задания понадобится таблица production.orderstatuslog для поиска закрытых заказов по новой логике. Будут использоватся следующие поля:
- order_id для джойна на production.orders
- status_id для определения статуса заказа


## 1.3. Проанализируйте качество данных

-----------

### Оцените, насколько качественные данные хранятся в источнике.

Для проверки качественности исходных данных достаточно было посмотреть на DDL таблиц:
- во всех таблицах присутствуют PK и FK
- четко прописаны проверки для всех денежных полей
- прописаны наборы полей которые должны быть уникальны
- и так далее

Все эти проверки обеспечивают качественность исходных данных, так как некачественные данные не загрузятся в эти таблицы.

### Укажите, какие инструменты обеспечивают качество данных в источнике.

| Таблицы                   | Объект                                                                                                  | Инструмент               | Для чего используется                           |
| ------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------ | ----------------------------------------------- |
| production.orderitems     | id integer generated always as identity primary key                                                     | Первичный ключ           | Уникальность поля id                            |
| production.orderitems     | product_id integer not null references products                                                         | Внешний ключ             | Целостность связей с табличей product           |
| production.orderitems     | order_id integer not null references orders                                                             | Внешний ключ             | Целостность связей с табличей orders            |
| production.orderitems     | price numeric(19, 5) default 0 not null constraint orderitems_price_check check (price >= (0)::numeric) | Ограничение проверка     | Цена больше 0                                   |
| production.orderitems     | quantity integer not null constraint orderitems_quantity_check check (quantity > 0)                     | Ограничение проверка     | Количество больше 0                             |
| production.orderitems     | unique (order_id, product_id)                                                                           | Ограничение уникальность | Уникальность связи продукта и товара            |
| production.orderitems     | constraint orderitems_check check ((discount >= (0)::numeric) AND (discount <= price))                  | Ограничение проверка     | 0 <= скидка <= цена                             |
| production.orderitems     | orderitems_order_id_product_id_key                                                                      | Индекс                   | Оптимизированный поиск по order_id и product_id |
| production.orderitems     | orderitems_pkey                                                                                         | Индекс                   | Оптимизированный поиск по первичному ключу      |
| production.orders         | order_id integer not null primary key                                                                   | Первичный ключ           | Уникальность заказов                            |
| production.orders         | constraint orders_check check (cost = (payment + bonus_payment))                                        | Ограничение проверка     | Стоимость = платеж + платеж бонусами            |
| production.orders         | orders_pkey                                                                                             | Индекс                   | Оптимизированный поиск по первичному ключу      |
| production.orderstatuses  | id integer not null primary key                                                                         | Первичный ключ           | Уникальность статусов заказов                   |
| production.orderstatuses  | orderstatuses_pkey                                                                                      | Индекс                   | Оптимизированный поиск по первичному ключу      |
| production.orderstatuslog | id integer generated always as identit primary key                                                      | Первичный ключ           | Уникальность поля id                            |
| production.orderstatuslog | order_id integer not nul references production.orders                                                   | Внешний ключ             | Целостность связей с табличей orders            |
| production.orderstatuslog | status_id integer not nul references production.orderstatuses                                           | Внешний ключ             | Целостность связей с табличей orderstatuses     |
| production.orderstatuslog | unique (order_id, status_id)                                                                            | Ограничение уникальность | Уникальность связи заказа и его статуса         |
| production.orderstatuslog | orderstatuslog_order_id_status_id_key                                                                   | Индекс                   | Оптимизированный поиск по order_id и status_id  |
| production.orderstatuslog | orderstatuslog_pkey                                                                                     | Индекс                   | Оптимизированный поиск по первичному ключу      |
| production.products       | id integer not null primary key                                                                         | Первичный ключ           | Уникальность товаров                            |
| production.products       | price numeric(19, 5) default 0 not null constraint products_price_check check (price >= (0)::numeric)   | Ограничение проверка     | Цена больше 0                                   |
| production.products       | products_pkey                                                                                           | Индекс                   | Оптимизированный поиск по первичному ключу      |
| production.users          | id integer not null primary key                                                                         | Первичный ключ           | Уникальность пользователей                      |
| production.users          | users_pkey                                                                                              | Индекс                   | Оптимизированный поиск по первичному ключу      |

## 1.4. Подготовьте витрину данных

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

```SQL
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
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

```SQL
drop table if exists analysis.dm_rfm_segments;
create table analysis.dm_rfm_segments (
    user_id integer not null primary key references production.users(id),
    recency integer not null check (recency between 1 and 5),
    frequency integer not null check (frequency between 1 and 5),
    monetary_value integer not null check (monetary_value between 1 and 5)
);

drop table if exists analysis.tmp_rfm_recency;
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
drop table if exists analysis.tmp_rfm_frequency;
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
drop table if exists analysis.tmp_rfm_monetary_value;
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);
```

### 1.4.3. Напишите SQL запрос для заполнения витрины

```SQL
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

truncate analysis.dm_rfm_segments;
insert into analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
select
    user_id,
    r.recency,
    f.frequency,
    m.monetary_value
from analysis.tmp_rfm_recency as r
inner join analysis.tmp_rfm_frequency as f using (user_id)
inner join analysis.tmp_rfm_monetary_value as m using (user_id);
```

## 2. Доработка представлений

```SQL
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
```