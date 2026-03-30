--create database sport_shop;

create table employees
(
    id serial not null primary key,
	full_name varchar(100) not null,
    position varchar(50) not null,
    hire_date date not null,
    gender varchar(10) not null,
    salary numeric not null
);

create table customers
(
    id serial not null   primary key,
    full_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(20) not null,
    gender varchar(10) not null,
    order_history text,
    discount_rate float not null,
    subscribed_to_newspaper boolean not null
);

create table products
(
    id serial not null   primary key,
    product_name varchar(100) not null,
    category varchar(50) not null,
    quantity_in_stock int not null,
    cost_price numeric not null,
    manufacturer varchar(100) not null,
    selling_price numeric not null
);

create table sales
(
    id serial not null   primary key,
    product_id int not null,
    selling_price numeric not null,
    quantity_sold int not null,
    sale_date timestamp not null,
    seller_id int not null,
    customer_id int,
    foreign key (product_id) references products(id) on delete cascade,
    foreign key (seller_id) references employees(id),
    foreign key (customer_id) references customers(id)
);

create table sales_history
(
    id serial not null   primary key,
    product_id int not null,
    selling_price numeric not null,
    quantity_sold int not null,
    sale_date timestamp not null,
    seller_id int not null,
    customer_id int,
    foreign key (product_id) references products(id) on delete cascade,
    foreign key (seller_id) references employees(id),
    foreign key (customer_id) references customers(id)
);

create table product_archive
(
    id serial not null  primary key,
    product_name varchar(100) not null,
    category varchar(50) not null,
    cost_price numeric not null,
    manufacturer varchar(100) not null,
    selling_price numeric not null,
    date_archived timestamp not null
);

create table employee_archive
(
    id serial not null   primary key,
    full_name varchar(100) not null,
    position varchar(50) not null,
    hire_date date not null,
    gender varchar(10) not null,
    salary numeric not null,
    date_archived timestamp not null
);

create table last_unit
(
    id serial not null   primary key,
    product_id int not null,
    quantity_left int not null,
    foreign key (product_id) references products(id)
);


insert into products (product_name, category, quantity_in_stock, cost_price, manufacturer, selling_price) values
( 'Running Shoes',  'Footwear', 50, 500.00,  'Sports Co.', 1000.00),
( 'Tennis Racket',  'Equipment', 30, 700.00,  'Tennis Pro', 1400.00),
( 'Football Jersey',  'Apparel', 100, 200.00,  'Sportswear Inc.', 400.00),
( 'Yoga Mat',  'Accessories', 40, 300.00,  'Fitness Gear', 600.00),
( 'Basketball',  'Equipment', 20, 400.00,  'PlayHard', 800.00);


insert into employees (full_name, position, hire_date, gender, salary) values
( 'John Smith',  'Salesperson', '2010-01-15',  'Male', 30000.00),
( 'Anna Brown',  'Cashier', '2012-07-22',  'Female', 25000.00),
( 'Michael Green',  'Manager', '2015-03-10',  'Male', 45000.00),
( 'Susan White',  'Accountant', '2018-09-28',  'Female', 35000.00),
( 'Linda Black',  'Inventory Specialist', '2020-05-12',  'Female', 32000.00);


insert into customers (full_name, email, phone, gender, order_history, discount_rate, subscribed_to_newspaper) values
( 'Peter Parker',  'peterparker@example.com',  '1234567890',  'Male',  '', 0.05, true),
( 'Mary Jane',  'maryjane@example.com',  '0987654321',  'Female',  '', 0.10, false),
( 'Tony Stark',  'tonystark@example.com',  '1122334455',  'Male',  '', 0.15, true),
( 'Bruce Wayne',  'brucewayne@example.com',  '5566778899',  'Male',  '', 0.20, false),
( 'Diana Prince',  'dianaprince@example.com',  '6677889900',  'Female',  '', 0.25, true);

create or replace function unique_customers_count()
returns int as $$
declare
    v_count int;
begin
    select count(distinct customer_id) into v_count
    from sales
    where customer_id is not null;
    return v_count;
end;
$$ language plpgsql;


create or replace function avg_price_by_category(p_category varchar)
returns numeric as $$
declare
    v_avg numeric;
begin
    select avg(selling_price) into v_avg
    from products
    where category = p_category;
    return v_avg;
end;
$$ language plpgsql;


create or replace function avg_sale_price_per_date()
returns table(sale_date date, avg_price numeric) as $$
begin
    return query
    select date(sales.sale_date), avg(sales.selling_price)
    from sales
    group by date(sales.sale_date)
    order by date(sales.sale_date);
end;
$$ language plpgsql;



create or replace function last_sold_product()
returns table(product_id int, product_name varchar, sale_date timestamp) as $$
begin
    return query
    select p.id, p.product_name, s.sale_date
    from sales s
    join products p on s.product_id = p.id
    order by s.sale_date desc
    limit 1;
end;
$$ language plpgsql;

create or replace function first_sold_product()
returns table(product_id int, product_name varchar, sale_date timestamp) as $$
begin
    return query
    select p.id, p.product_name, s.sale_date
    from sales s
    join products p on s.product_id = p.id
    order by s.sale_date asc
    limit 1;
end;
$$ language plpgsql;

create or replace function products_by_category_and_manufacturer(
    p_category varchar,
    p_manufacturer varchar
)
returns table(product_id int, product_name varchar, selling_price numeric) as $$
begin
    return query
    select products.id, products.product_name, products.selling_price
    from products
    where category = p_category
      and manufacturer = p_manufacturer;
end;
$$ language plpgsql;

create or replace function employees_with_45_year_anniversary()
returns table(employee_id int, full_name varchar, hire_date date) as $$
begin
    return query
    select employees.id, employees.full_name, employees.hire_date
    from employees
    where extract(year from age(current_date, employees.hire_date)) = 45;
end;
$$ language plpgsql;


insert into sales (product_id, selling_price, quantity_sold, sale_date, seller_id, customer_id)
values
(1, 1000.00, 2, '2024-01-10 10:00:00', 1, 1),
(2, 1400.00, 1, '2024-02-15 15:30:00', 2, 2),
(3, 400.00, 3, '2024-03-20 12:45:00', 3, 3),
(4, 600.00, 1, '2024-04-05 09:20:00', 4, 4),
(5, 800.00, 2, '2024-05-12 18:10:00', 5, 5);


select unique_customers_count();
select avg_price_by_category('Footwear');
select * from avg_sale_price_per_date();
select * from last_sold_product();
select * from first_sold_product();
select * from products_by_category_and_manufacturer('Equipment', 'Tennis Pro');
select * from employees_with_45_year_anniversary();



