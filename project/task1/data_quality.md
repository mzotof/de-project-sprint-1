# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.

Для проверки качественности исходных данных достаточно было посмотреть на DDL таблиц:
- во всех таблицах присутствуют PK и FK
- четко прописаны проверки для всех денежных полей
- прописаны наборы полей которые должны быть уникальны
- и так далее

Все эти проверки обеспечивают качественность исходных данных, так как некачественные данные не загрузятся в эти таблицы.

## Укажите, какие инструменты обеспечивают качество данных в источнике.

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