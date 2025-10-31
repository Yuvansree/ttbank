create table ttsbank_banks (
bank_id number,
bank_code varchar2(25),
bank_location varchar2(30) not null,
is_headoffice char(1) not null,
constraint bank_id_pk primary key (bank_id),
constraint bank_code unique (bank_code)
);

begin
insert into ttsbank_banks(bank_id, bank_code, bank_location, is_headoffice)
 values(1000,'ttsbnk001','chennai','y');
insert into ttsbank_banks(bank_id, bank_code, bank_location, is_headoffice)
 values(1001,'ttsbnk002','madurai','n');
insert into ttsbank_banks(bank_id, bank_code, bank_location, is_headoffice)
 values(1002,'ttsbnk003','coimbatore','n');
end;
/

create table ttsbank_products (
product_id number,
product_name varchar2(25) not null,
product_code varchar2(5) not null,
constraint prod_id_pk primary key (product_id)
);

begin
insert into ttsbank_products(product_id, product_name,product_code)
values(2000,'savings bank','sb');
insert into ttsbank_products(product_id, product_name,product_code)
values(2001,'current','cb');
insert into ttsbank_products(product_id, product_name,product_code)
values(2002,'business','bb');
end;
/


create table ttsbank_sub_products (
sub_product_id number,
product_id number,
features varchar2(25) not null,
balance_limit number not null,
withdraw_limit number not null,
constraint sub_product_id_pk primary key (sub_product_id),
constraint prod_id_fk foreign key (product_id) references ttsbank_products (product_id)
);

begin
insert into ttsbank_sub_products (sub_product_id, product_id, features,balance_limit, withdraw_limit)
values(3000,2000,'Silver',5000,50000);
insert into ttsbank_sub_products (sub_product_id, product_id, features,balance_limit, withdraw_limit)
values(3001,2000,'Gold',10000,100000);
insert into ttsbank_sub_products (sub_product_id, product_id, features,balance_limit, withdraw_limit)
values(3002,2000,'Platinum',15000,2500000);
end;
/


create table ttsbank_customers ( 
    customer_id number,
    customer_name varchar2(50) not null,
    customer_phno number not null,
    customer_mail varchar2(100),
    aadhar_no number not null,
    pan_no varchar2(50) not null,
    password varchar2(15),
    constraint customer_id primary key (customer_id),
    constraint customer_phno_uk unique (customer_phno),
    constraint customer_mail_uk unique (customer_mail),
    constraint aadhar_no_uk unique (aadhar_no),
    constraint pan_no_uk unique (pan_no)
);

create table ttsbank_cus_products (
    cus_product_id  number,
    sub_product_id number,
    customer_id number,
    account_no number not null,
    account_open_on date default sysdate,
    status varchar2(25) default 'Active',
    available_balance number not null,
    bank_id number,
    constraint cus_product_id_pk primary key (cus_product_id),
    constraint sub_product_id_fk foreign key (sub_product_id) references ttsbank_sub_products (sub_product_id),
    constraint customer_id_fk foreign key (customer_id) references ttsbank_customers (customer_id),
    constraint bank_id_fk foreign key (bank_id) references ttsbank_banks (bank_id),
    constraint account_no_uk unique (account_no)
    );
 

create table ttsbank_cus_transactions (
    cus_trans_id number,
    cus_product_id number,
    trans_amount number not null,
    trans_type char(1),
    trans_on date default sysdate,
    benef_account varchar2(25) not null,
    trans_mode varchar2(50) not null,
    account_balance number not null,
    constraint cus_trans_id_pk primary key (cus_trans_id),
    constraint cus_product_id_fk foreign key (cus_product_id) references ttsbank_cus_products (cus_product_id),
    constraint trans_type_ck check (trans_type in ('c','d'))
    );

 create table ttsbank_password_track (
    track_id number,
    customer_id number,
    customer_password varchar2(50) not null,
    password_changed_on date default sysdate,
    constraint track_id_pk primary key (track_id),
    constraint customer_track_id_fk foreign key (customer_id) references ttsbank_customers (customer_id)
    );
    
 select * from ttsbank_banks;
 
 select * from ttsbank_products;
 
 select * from ttsbank_sub_products;
 
 select * from ttsbank_customers;
 
 select * from ttsbank_cus_products;
 
 select * from ttsbank_cus_transactions;
 
 select * from ttsbank_password_track;
 
 ------------------------------------------------------------------------------

create sequence sq1;

create sequence sq2;

create sequence sq3;

create sequence sq4 start with 10000000;
   
create or replace procedure ttsbank_newaccount
(
    cus_name in varchar2,
    cus_phno in number,
    cus_mail in varchar2,
    cus_aadhar in number,
    cus_pan in varchar2,
    cus_pwd in varchar2,
    cus_sub_prod_id in number,
    p_trans_amount in number,
    trans_type in varchar2,
    benef_account in varchar2,
    trans_mode in varchar2,
    flag in number,
    p_accn_no  in number,
    msg out varchar2
)as
cid number;
cpid number;
accno number;
v_cus_product number;
v_available_bal number;
v_bal_limit  number;
v_withdraw_limit number;
v_limit number;
v_customer_id number;
v_count number;
v_password varchar2(50);
begin
if flag = 1 then
insert into ttsbank_customers(CUSTOMER_ID, CUSTOMER_NAME, CUSTOMER_PHNO,CUSTOMER_MAIL, AADHAR_NO, PAN_NO, PASSWORD)
values(sq1.nextval,cus_name,cus_phno,cus_mail,cus_aadhar,cus_pan,cus_pwd) returning customer_id into cid;
insert into ttsbank_cus_products (CUS_PRODUCT_ID, SUB_PRODUCT_ID, CUSTOMER_ID, ACCOUNT_NO,AVAILABLE_BALANCE)
values (sq2.nextval,cus_sub_prod_id,cid,sq4.nextval,p_trans_amount)
returning cus_product_id,account_no into cpid,accno;
insert into ttsbank_cus_transactions(CUS_TRANS_ID, CUS_PRODUCT_ID, TRANS_AMOUNT, 
TRANS_TYPE,BENEF_ACCOUNT, TRANS_MODE, ACCOUNT_BALANCE) 
values (sq3.nextval,cpid,p_trans_amount,trans_type,benef_account,trans_mode,p_trans_amount);
msg := 'Account Opened - and your account no is'||accno;
commit;
dbms_output.put_line(msg);
elsif flag = 2 then
select CUS_PRODUCT_ID, available_balance into v_cus_product , v_available_bal      -- to get input from user account_no and to compare get cus_product_id
from ttsbank_cus_products                     
where account_no = p_accn_no;
  select BALANCE_LIMIT, WITHDRAW_LIMIT into v_bal_limit , v_withdraw_limit      -- to get data for check bal_limit and withdraw limit   
from ttsbank_sub_products 
where sub_product_id = (select sub_product_id from ttsbank_cus_products 
where CUS_PRODUCT_ID = v_cus_product);
dbms_output.put_line(1);
select case when v_withdraw_limit >= nvl(sum(a.trans_amount),0) + p_trans_amount 
then 1 else 0 end into v_limit      -- to using condition for check withdraw limit 
from ttsbank_cus_transactions a
where (cus_product_id = v_cus_product and to_char(trans_on,'dd-mon-yyyy') = to_char(sysdate,'dd-mon-yyyy') )and TRANS_TYPE in ('d','D');
    dbms_output.put_line(v_limit);
if (trans_type in ('D','d') and v_bal_limit <=(v_available_bal - p_trans_amount) and v_limit = 1) or trans_type in ('C','c') then
insert into ttsbank_cus_transactions(CUS_TRANS_ID, CUS_PRODUCT_ID, TRANS_AMOUNT, 
TRANS_TYPE,BENEF_ACCOUNT, TRANS_MODE, ACCOUNT_BALANCE) 
values (sq3.nextval, v_cus_product,p_trans_amount,trans_type,benef_account,trans_mode,
case when trans_type in ('C','c') then v_available_bal + p_trans_amount 
when trans_type in ('D','d') then v_available_bal - p_trans_amount end 
) returning account_balance into v_available_bal;
update ttsbank_cus_products set available_balance = v_available_bal where account_no = p_accn_no;
msg := case when trans_type in ('D','d') then 'Debit Success'
when trans_type in ('C','c') then 'Credit Success' end ;
commit;
dbms_output.put_line(msg);
else
raise_application_error(-20000,'Insufficient fund or reached withdraw limit');
end if;
elsif flag = 3 then
select customer_id into v_customer_id
from ttsbank_cus_products                     
where account_no = p_accn_no;
select  count(*) into v_count from
(select customer_password ,customer_id, 
dense_rank()over(partition by customer_id order by password_changed_on desc) as d 
from ttsbank_password_track where customer_id = v_customer_id ) where customer_password = cus_pwd and d<= 3;
select password into v_password from ttsbank_customers where customer_id = v_customer_id;
if v_count > 0 or v_password = cus_pwd then 
msg := 'existing password must be changed';
dbms_output.put_line(msg);
else
update ttsbank_customers set PASSWORD =  cus_pwd where customer_id = v_customer_id;
msg:= 'password updated';
dbms_output.put_line(msg);
end if;
end if;
exception
when others then
dbms_output.put_line(sqlerrm);
end;
/

create sequence sq5 ;

create or replace trigger ttsbank_password after update of customer_id, password on ttsbank_customers for each row
declare
pragma autonomous_transaction ;
begin
insert into ttsbank_password_track (TRACK_ID, CUSTOMER_ID, CUSTOMER_PASSWORD, PASSWORD_CHANGED_ON)
values (sq5.nextval,:old.customer_id,:old.password, sysdate);
commit; 
end;
/


declare
v varchar2(50);
begin
ttsbank_newaccount(cus_name => 'Rajesh',
cus_phno => 7209467851, 
cus_mail => 'n@gmail.com', 
cus_aadhar =>123443008888,
cus_pan=>'net',
cus_pwd=> 'one',
cus_sub_prod_id => 3000,
p_trans_amount=>1000,
trans_type=>'d',
benef_account=> 'self',
trans_mode=> 'upi',
flag => 3,
p_accn_no => 10000005,
msg => v);
end;
/

--truncate table ttsbank_password_track;

select * from ttsbank_customers;

select * from ttsbank_password_track;

select * from ttsbank_cus_products;

select * from ttsbank_customers;

update ttsbank_customers set password = 'nethaji@1997' where customer_id = 1;

select * from ttsbank_cus_products;

select customer_password from
(select customer_password , dense_rank()over(partition by customer_id order by password_changed_on desc) as d 
from ttsbank_password_track) where customer_id = 1 and d <= 3;


select first_name from employees order by first_name desc;


select * from ttsbank_password_track;

delete from ttsbank_password_track where customer_id = 1;

commit;

select name , count(type) from user_source where type = 'PROCEDURE' GROUP BY NAME ;

select * from (select nvl(customer_password,0) as track_password ,customer_id, 
dense_rank()over(partition by customer_id order by password_changed_on desc) as d 
from ttsbank_password_track )where customer_id = 1 and d <= 3 ;
