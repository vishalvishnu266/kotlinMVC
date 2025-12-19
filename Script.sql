show tables;


CREATE TABLE trades(
 id bigint,
 buyer_id integer,
 symbol text,
 order_quantity integer,
 bid_price numeric(5,2),
 order_time timestamp
);


select * from trades;

SELECT generate_series(1,5);

select random(1,10);

SELECT id,
(array['AAPL','F','DASH'])[random(1,3)] AS symbol
FROM generate_series(1,5) AS id;

SELECT
 id,
 random(1,10) as buyer_id,
 (array['AAPL','F','DASH'])[random(1,3)] as symbol,
 random(1,20) as order_quantity,
 round(random(10.00,20.00), 2) as bid_price,
 now() as order_time
FROM generate_series(1,1000) AS id;

INSERT INTO trades (id, buyer_id, symbol,
 order_quantity, bid_price, order_time)
SELECT
 id,
 random(1,10) as buyer_id,
 (array['AAPL','F','DASH'])[random(1,3)] as symbol,
 random(1,20) as order_quantity,
 round(random(10.00,20.00), 2) as bid_price,
 now() as order_time
FROM generate_series(1,1000) AS id;


select * from trades;



SELECT symbol, count(*) AS total_volume
FROM trades
GROUP BY symbol
ORDER BY total_volume DESC;

SELECT buyer_id, sum(bid_price * order_quantity) AS total_value
FROM trades
GROUP BY buyer_id
ORDER BY total_value DESC
LIMIT 3;


SELECT buyer_id, sum(bid_price * order_quantity) AS total_value
FROM trades
GROUP BY buyer_id
ORDER BY buyer_id ;


SELECT datname FROM pg_database;

select * from pg_database;


CREATE SCHEMA products;
CREATE SCHEMA customers;
CREATE SCHEMA sales;



CREATE TABLE products.catalog (
    id SERIAL PRIMARY KEY,
    name VARCHAR (100) NOT NULL,
    description TEXT NOT NULL,
    category TEXT CHECK (category IN ('coffee', 'mug', 't-shirt')),
    price NUMERIC(10, 2),
    stock_quantity INT CHECK (stock_quantity >= 0)
);


CREATE TABLE products.reviews (  
    id BIGSERIAL PRIMARY KEY,  
    product_id INT,
    customer_id INT,
    review TEXT,
    rank SMALLINT 
);


INSERT INTO products.catalog (name, description, category, price, stock_quantity)
VALUES
    ('Sunrise Blend', 'A smooth and balanced blend with notes of caramel and citrus.', 'coffee', 14.99, 50),
    ('Midnight Roast', 'A dark roast with rich flavors of chocolate and toasted nuts.', 'coffee', 16.99, 40),
    ('Morning Glory', 'A light roast with bright acidity and floral notes.', 'coffee', 13.99, 30),
    ('Sunrise Brew Co. Mug', 'A ceramic mug with the Sunrise Brew Co. logo.', 'mug', 9.99, 100),
    ('Sunrise Brew Co. T-Shirt', 'A soft cotton t-shirt with the Sunrise Brew Co. logo.', 't-shirt', 19.99, 25);



SHOW search_path;

SET search_path TO products,public;


select  * from products.catalog;



-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

create table public.users (
  id serial not null,
  name text not null,
  email text null,
  active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  constraint users_pkey primary key (id),
  constraint users_email_key unique (email)
) TABLESPACE pg_default;

create table public.orders (
  id serial not null,
  user_id integer not null,
  total numeric(12, 2) not null,
  status text not null,
  placed_at timestamp with time zone not null default now(),
  constraint orders_pkey primary key (id),
  constraint orders_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;


INSERT INTO "public"."users" ("id", "name", "email", "active", "created_at") VALUES ('1', 'Alice', 'alice@example.com', 'true', '2025-12-15 09:31:59.359053+00'), ('2', 'Bob', 'bob@example.com', 'true', '2025-12-15 09:31:59.359053+00'), ('3', 'Carol', 'carol@example.com', 'false', '2025-12-15 09:31:59.359053+00');


INSERT INTO "public"."orders" ("id", "user_id", "total", "status", "placed_at") VALUES ('1', '1', '120.50', 'PAID', '2025-12-15 09:31:59.359053+00'), ('2', '1', '35.00', 'PENDING', '2025-12-15 09:31:59.359053+00'), ('3', '2', '250.00', 'PAID', '2025-12-15 09:31:59.359053+00'), ('4', '2', '18.75', 'CANCELLED', '2025-12-15 09:31:59.359053+00');





SELECT jsonb_agg(u_row) FROM (
  SELECT
    to_jsonb(u) - 'id' || jsonb_build_object('id', u.id) ||
    jsonb_build_object(
      'orders', COALESCE(o.orders, '[]'::jsonb)
    ) AS u_row
  FROM public.users u
  LEFT JOIN (
    SELECT user_id, jsonb_agg(to_jsonb(o) - 'user_id') AS orders
    FROM public.orders o
    GROUP BY user_id
  ) o ON o.user_id = u.id
) s;


CREATE OR REPLACE FUNCTION public.get_users_with_orders()
RETURNS jsonb
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_agg(u_row) FROM (
    SELECT
      to_jsonb(u) - 'id' || jsonb_build_object('id', u.id) ||
      jsonb_build_object(
        'orders', COALESCE(o.orders, '[]'::jsonb)
      ) AS u_row
    FROM public.users u
    LEFT JOIN (
      SELECT user_id, jsonb_agg(to_jsonb(o) - 'user_id') AS orders
      FROM public.orders o
      GROUP BY user_id
    ) o ON o.user_id = u.id
  ) s;
$$;





