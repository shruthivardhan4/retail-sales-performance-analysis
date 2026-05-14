create database ecommerce_project;
use ecommerce_project;

create table olist_order_payments_dataset
(order_id varchar(250), payment_sequential int, payment_type varchar(100),
payment_installments int, payment_value int);

load data infile 'C:/olist_order_payments_dataset.csv' into table olist_order_payments_dataset
fields terminated by ','
ignore 1 lines;

SHOW VARIABLES LIKE 'secure_file_priv';

select * from olist_order_payments_dataset;
drop table olist_order_payments_dataset;

create table olist_orders_dataset
(order_id varchar(200), customer_id varchar(200), order_status varchar(200),
order_purchase_timestamp text, order_approved_at text,
order_delivered_carrier_date text, order_delivered_customer_date text,
order_estimated_delivery_date text);

select * from olist_orders_dataset;
drop table olist_orders_dataset;
describe olist_orders_dataset;

LOAD DATA INFILE 'C:/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
enclosed by ""
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET sql_mode='';

select * from olist_orders_dataset;

-- 1st KPI
select case
when dayname(order_purchase_timestamp) in ('Saturday', 'Sunday') then 'Weekend' else 'Weekday'
end as day_type, count(distinct o.order_id) as total_orders,
round(avg(p.payment_value),0) as average_payment,
round(sum(p. payment_value),0) as total_sales
from olist_orders_dataset o join olist_order_payments_dataset p on o.order_id = p.order_id group by day_type;


create table olist_order_reviews_dataset
(review_id varchar(250), order_id varchar(250), review_score int);

LOAD DATA INFILE 'C:/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from olist_order_reviews_dataset;
select * from olist_order_payments_dataset;

-- 2nd KPI

select 
count(distinct o.order_id) as Total_orders
from olist_orders_dataset o join olist_order_reviews_dataset r on o.order_id = r.order_id
join olist_order_payments_dataset p on o.order_id =p.order_id where r.review_score = 5 and p.payment_type = 'credit_card';


-- 3rd KPI
create table olist_products_dataset
(product_id varchar(250), product_category_name varchar(200), product_name_lenght int default 0,
product_description_lenght int, product_photos_qty int, product_weight_g int,
product_length_cm int, product_height_cm int, product_width_cm int);

select * from olist_products_dataset;

LOAD DATA INFILE 'C:/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 0) AS Average_days
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset pr ON oi.product_id = pr.product_id
WHERE pr.product_category_name = 'pet_shop';


-- 4th KPI
create table olist_order_items_dataset
(order_id varchar(200), order_item_id int, product_id varchar(200),
seller_id varchar(200), shipping_limit_date date, price int, freight_value int);

LOAD DATA INFILE 'C:/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from olist_order_items_dataset;

create table olist_customers_dataset
(customer_id varchar(250), customer_unique_id varchar(250), customer_zip_code_prefix int, customer_city varchar(200), customer_state varchar(100));

LOAD DATA INFILE 'C:/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from olist_customers_dataset;

SELECT ROUND(AVG(oi.price), 0) AS Average_Price, ROUND(AVG(p.payment_value), 0) AS Average_payment
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi ON oi.order_id = o.order_id
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE c.customer_city = 'Sao Paulo';


-- 5th KPI

select r.review_score, round(avg(datediff(o.order_delivered_customer_date, o.order_purchase_timestamp)),0) as Average_shipping_days
from olist_orders_dataset o
join olist_order_reviews_dataset r on o.order_id = r.order_id
group by r.review_score order by review_score;