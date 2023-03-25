create table category (id number(6,0) primary key,
                      name varchar2(50) not null);
                      
select * from category;

create sequence seqcategory start with 5 increment by 5;

insert into category(id,name)values(seqcategory.nextval, 'floorcleaner');
insert into category(id,name)values(seqcategory.nextval, 'detergent');
insert into category(id,name)values(seqcategory.nextval, 'airfreshner');
insert into category(id,name)values(seqcategory.nextval, 'dishwasher');

select * from category;

create table products(id number(5,0) primary key,
                    name varchar2(50) not null,
                    price number(8,2),
                    category_id number(6,0) references category(id));
                    
select * from products;
 
create sequence seqproduct start with 10 increment by 10;

insert into products(id, name, price, category_id)values(seqproduct.nextval, 'domex', 300, 5);

insert into products(id, name, price, category_id)values(seqproduct.nextval, 'tide', 500, 10);

insert into products(id, name, price, category_id)values(seqproduct.nextval, 'odonil', 200.55, 15);

insert into products(id, name, price, category_id)values(seqproduct.nextval, 'vim', 150, 15);

select * from products;

select * from products p, category c
where p.category_id = c.id;
-------------------------------------------------------------------------------

create table cities(id number(4,0) primary key,
                    name varchar2(30) not null);
                    
create sequence seqcity;

insert into cities(id, name)values(seqcity.nextval, 'mumbai');
insert into cities(id, name)values(seqcity.nextval, 'pune');
insert into cities(id, name)values(seqcity.nextval, 'nagpur');
insert into cities(id, name)values(seqcity.nextval, 'nashik');
insert into cities(id, name)values(seqcity.nextval, 'kolhapur');

select * from cities;
------------------------------------------------------------------------------

create table customers(id number(7,0) primary key,
                       name varchar2(50) not null,
                       locationid number(4,0),
                       email varchar2(100) unique,
                       dob date,
                       cityid number(4,0) references cities(id)
                       );
                       
alter table customers drop constraint SYS_C008267;

alter table customers add foreign key (cityid) references cities(id);

select * from customers; 

drop sequence seqcust;

create sequence seqcust start with 3 increment by 3;

insert into customers(id, name, locationid, email, dob, cityid)values(seqcust.nextval, 'ravi',121,'test.gmail','03-may-91',4);
insert into customers(id, name, locationid, email, dob, cityid)values(seqcust.nextval, 'sham',123,'test1.gmail','30-mar-90',2);
insert into customers(id, name, locationid, email, dob, cityid)values(seqcust.nextval, 'shree',123,'test2.gmail','11-apr-90',1);
insert into customers(id, name, locationid, email, dob, cityid)values(seqcust.nextval, 'neha',115,'test3.gmail','11-feb-93',3);

select * from customers;

select * from customers c, cities z
where c.cityid = z.id ;

--------------------------------------------------------------------------------------------------------------------------------------------------

drop table transactions;

create table transactions(txid number(5,0) primary key,
txtime timestamp, 
custid number(7,0) references customers(id),
prodid number(5,0) references products(id),
qty number(3)
);

select * from transactions;

desc transactions;

select * from products;

desc products;

create sequence seqtran start with 2 increment by 3;

insert into transactions(txid, txtime, custid, prodid, qty)
values(seqtran.nextval, '20-jan-05', 6, 10, 50);

insert into transactions(txid, txtime, custid, prodid, qty)
values(seqtran.nextval, '20-jan-05', 6, 40, 40);

insert into transactions(txid, txtime, custid, prodid, qty)
values(seqtran.nextval, '20-jan-05', 6, 20, 5);

insert into transactions(txid, txtime, custid, prodid, qty)
values(seqtran.nextval, '20-jan-05', 9, 30, 15);

select * from transactions t, customers c, products p
where t.custid = c.id
and   t.prodid = p.id;


------------------------------------------------------------------------------------

--customer purchase details

--cat wise purchase value end no of transactions

select cat.name catname, sum(t.qty * p.price) purchasevalue, count(t.txid) totalpurchases
from transactions t, customers c, products p, category cat
where t.custid = c.id
and   t.prodid = p.id
and   p.category_id = cat.id
group by cat.name
order by purchasevalue desc;

-- top 2 selling categories

select *
from(
    select rownum idx, catname, purchasevalue
    from (
            select cat.name catname, sum(t.qty * p.price) purchasevalue
            from transactions t, customers c, products p, category cat
            where t.custid = c.id
            and   t.prodid = p.id
            and   p.category_id = cat.id
            group by cat.name
            order by purchasevalue desc
        )
    )
where idx <= 2;

-- top 2 selling products

select *
from(
    select rownum idx, prodname, purchasevalue
    from (
            select p.name prodname, sum(t.qty * p.price) purchasevalue
            from transactions t, customers c, products p
            where t.custid = c.id
            and   t.prodid = p.id
            group by p.name
            order by purchasevalue desc
        )
    )
where idx <= 2;

--highest sales in day
select to_date(to_char(t.txtime, 'dd-Mon-yy')) txdate, t.qty * p.price sales
from transactions t, products p
where t.prodid = p.id;

---- daily sales
select txdate, sum(sales) sumsales
from (
        select to_date(to_char(t.txtime, 'dd-Mon-yy')) txdate, t.qty * p.price sales
        from transactions t, products p
        where t.prodid = p.id
    )
group by txdate;


--date wise sales

select txdate, to_number(to_char(txdate, 'dd')),  sales
from (
        select to_date(to_char(t.txtime, 'dd-Mon-yy')) txdate, t.qty * p.price sales
        from transactions t, products p
        where t.prodid = p.id
    );
    
-- weekly sales   

select week, sum(sales)
from (
    select round((to_number(to_char(txdate, 'ddd')) / 7),0) week,  sales
    from (
            select to_date(to_char(t.txtime, 'dd-Mon-yy')) txdate, t.qty * p.price sales
            from transactions t, products p
            where t.prodid = p.id
        )
    )
group by week
order by week;

-- monthly sales 

select short_month, sum(sales)
from (
    select to_char(txdate, 'yyyy-mon') short_month,  sales
    from (
            select to_date(to_char(t.txtime, 'dd-Mon-yy')) txdate, t.qty * p.price sales
            from transactions t, products p
            where t.prodid = p.id
        )
    )
group by short_month
order by short_month;

 
