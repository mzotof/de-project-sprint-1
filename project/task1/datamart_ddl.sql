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
