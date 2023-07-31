create table user_info (
"created_at" TIMESTAMP not null default now(),
"updated_at" TIMESTAMP not null default now(),
"deleted_at" TIMESTAMP,
"id" uuid not null default uuid_generate_v4(),
"phone_number" character varying not null,
"email" character varying not null,
"password" character varying not null,
constraint "PK_user_id" primary key ("id")
);

create table address (
"created_at" TIMESTAMP not null default now(),
"updated_at" TIMESTAMP not null default now(),
"deleted_at" TIMESTAMP,
"id" uuid not null default uuid_generate_v4(),
"user_id" uuid not null,
"address_line_1" character varying not null,
"address_line_2" character varying not null,
"address_line_3" character varying not null,
"pincode" character varying not null,
constraint "PK_address_id" primary key ("id"),
constraint "FK_user_id" foreign key ("user_id") references user_info("id")
);

create table product (
"created_at" TIMESTAMP not null default now(),
"updated_at" TIMESTAMP not null default now(),
"deleted_at" TIMESTAMP,
"id" uuid not null default uuid_generate_v4(),
"name"  character varying not null, 
"description" character varying not null, 
"price" float not null,
"sku" character varying not null, 
"category" character varying not null,
constraint "PK_product_id" primary key ("id")
);

create table user_order (
"created_at" TIMESTAMP not null default now(),
"updated_at" TIMESTAMP not null default now(),
"id" uuid not null default uuid_generate_v4(),
"user_id" uuid not null,
"address_id" uuid not null,
"total_cost" float not null,
constraint "PK_order_id" primary key ("id"),
constraint "FK_user_id" foreign key ("user_id") references user_info("id"),
constraint "FK_address_id" foreign key ("address_id") references address("id")
);

create table order_product (
"order_id" uuid not null,
"product_id" uuid not null,
"count" integer not null,
constraint "FK_order_id" foreign key ("order_id") references user_order("id"),
constraint "FK_product_id" foreign key ("product_id") references product("id")
);

INSERT INTO public.user_info
(phone_number, email, "password")
values
('9999999999', 'user1@mail.com', 'pass1'),
('9999999998', 'user2@mail.com', 'pass2'),
('9999999997', 'user3@mail.com', 'pass3')
;

select * from user_info;

INSERT INTO public.address
(user_id, address_line_1, address_line_2, address_line_3, pincode)
values
((select id from user_info where email='user1@mail.com'), 'line11', 'line12', 'line13', '111111'),
((select id from user_info where email='user1@mail.com'), 'line21', 'line22', 'line23', '111122'),
((select id from user_info where email='user2@mail.com'), 'line31', 'line32', 'line33', '111133'),
((select id from user_info where email='user3@mail.com'), 'line41', 'line42', 'line43', '111144')
;

select * from address;


INSERT INTO public.product
("name", description, price, sku, category)
select 'product'||i::text, 'product_description'||i::text, i, 'SKU'||i::text, 'category1'
FROM generate_series(101, 105) AS t(i);

INSERT INTO public.product
("name", description, price, sku, category)
select 'product'||i::text, 'product_description'||i::text, i, 'SKU'||i::text, 'category2'
FROM generate_series(106, 110) AS t(i);

select * from product;

INSERT INTO public.user_order
(user_id, address_id, total_cost)
values
((select id from user_info where email='user1@mail.com'), (select id from address where address_line_1='line11'), 0),
((select id from user_info where email='user1@mail.com'), (select id from address where address_line_1='line21'), 0),
((select id from user_info where email='user1@mail.com'), (select id from address where address_line_1='line21'), 0),
((select id from user_info where email='user2@mail.com'), (select id from address where address_line_1='line31'), 0),
((select id from user_info where email='user3@mail.com'), (select id from address where address_line_1='line41'), 0)
;

select * from user_order;

INSERT INTO public.order_product
(order_id, product_id, count)
values
('45e2da64-caf9-436f-8396-d827d11ad644', '5eb87bce-166c-4216-a51a-118fe7239a59', 20),
('45e2da64-caf9-436f-8396-d827d11ad644', '84f0a83e-43c1-46b4-8f55-b8c5c3262aad', 10),
('45e2da64-caf9-436f-8396-d827d11ad644', 'd90389f4-cc01-466b-9b16-74e470364e15', 15),
('ead977ec-d682-42ff-940f-61ba2b5a3d36', 'd90389f4-cc01-466b-9b16-74e470364e15', 64),
('ead977ec-d682-42ff-940f-61ba2b5a3d36', 'abbdc4ab-5169-4c14-a905-2d81be716f8d', 32),
('14cae565-cdee-41bd-94c0-78f749c25d75', 'b3ffa73c-8018-4105-a8f7-35ca14e331fa', 66),
('a221d32c-b61e-4ec3-8c81-e87689d2296b', 'dd9f2429-7ecf-4ee4-95d8-f40d29885505', 90),
('fa62a426-db01-4462-954b-e26f66668118', 'aac8caa0-384a-4c32-b3ca-1919ce70160a', 100)
;

select * from order_product;

-- calculate total cost in user_order
update user_order as o set total_cost = (
select sum(op.count*p.price) from order_product op, product p where p.id = op.product_id and op.order_id = o.id)

select * from user_order;

create index email on user_info("email");
create index product_name on product("name");
create index product_category on product("category");
create index product_price on product("price");
create index order_user_id on user_order("user_id");