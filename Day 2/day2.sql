select EmployeeID from dbo.Employee
select DepartmentID from dbo.department  

-- Clustered Index
create index ix_Employee_EmployeeID on Employee(EmployeeID asc)
create index ix_Department_DepartmentID on Department(DepartmentID asc)

-- unique index
create unique index ix_Department_DepartmentName on Department(DepartmentName)

-- non clustered index
create nonclustered index idx_Employee_EmployeeID on Employee(EmployeeID asc)
create nonclustered index idx_Department_DepartmentID on Department(DepartmentID asc)

-- views
 --- create view
create view vWEmployeesFromITDepartment
as
select e.EmployeeName, e.EmployeeID, d.DepartmentID, d.DepartmentName
from dbo.Employee e
join dbo.Department d
on d.DepartmentID = e.DepartmentID

-- alter
alter view vWEmployeesFromITDepartment
as
select e.EmployeeName, e.EmployeeID, d.DepartmentID, d.DepartmentName
from dbo.Employee e
join dbo.Department d
on d.DepartmentID = e.DepartmentID
where d.DepartmentName = 'IT'

select * from vWEmployeesFromITDepartment

-- update from view
update vWEmployeesFromITDepartment set EmployeeName = 'Virat' where EmployeeID = 2

-- cannot insert into a table when it is dependent on other tables such as in joins, subqueries.

-- drop view
drop view vWEmployeesFromITDepartment

-- check view
exec sp_helptext vWEmployeesFromITDepartment

-- triggers

create table Employee_Audit_Test  (    
	ID int identity(1,1),
	empID int,
	audit_action varchar(255),
	audit_date   Date Default GETDATE()
)  

select * from Employee
select * from Employee_Audit_Test

create trigger trgEmployeeInsert
on dbo.Employee
for insert	
as
begin
    insert into Employee_Audit_Test(empID,audit_action,audit_date)
    select EmployeeID ,'INSERT',GETDATE() from inserted
end

insert into Employee values(9,'Arsh','Male','2003-09-11',4)

create trigger trgEmployeeUpdate
on dbo.Employee
after update
as
begin
    insert into Employee_Audit_Test(empID,audit_action,audit_date)
    select EmployeeID ,'UPDATE',GETDATE() from inserted
end

update Employee set DepartmentID = 3 where EmployeeID = 9

-- instead of trigger

create view vWEmployeesDetails
as
select EmployeeName, EmployeeID, EmployeeDOB, EmployeeGender,DepartmentID
from dbo.Employee 

select * from vWEmployeesDetails

select * from Employee
create trigger trgvWEmployeeDetails_InsteadOfInsert
on vwEmployeesDetails
instead of insert
as
begin
declare @DeptID int
select @DeptID= d.DepartmentID from Department d
join inserted i
on i.DepartmentID = d.DepartmentID
if(@DeptID is null)
begin
raiserror('Invalid Department ID. Statement Terminated',16,1)
return
end
insert into Employee(EmployeeID,EmployeeName,EmployeeGender,EmployeeDOB,DepartmentID)
select EmployeeID,EmployeeName,EmployeeGender,EmployeeDOB,@DeptID
from inserted
end

insert into vwEmployeesDetails values ('Aksh',10,'2001-09-01','Male',20)

-- Transactions

begin transaction
insert into sales.orders( customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
values(49,4,'2024-10-23','2024-11-04','2024-10-25',3,5)
insert into sales.order_items( order_id, item_id, product_id, quantity, list_price, discount)
values (80,2,9,3,399.99,0.05)
if @@ERROR = 0
begin
commit transaction
print 'Transaction Successfull'
end
else
begin
rollback transaction
print 'Something Went Wrong While Inserting Data'
end

select * from sales.order_items
select * from sales.orders

-- transaction A
begin transaction
update sales.customers set first_name = 'Alex' where customer_id = 1

waitfor delay '00:00:05'
update sales.orders set order_status = 3 where order_id = 1

commit transaction 


-- Transaction B
begin transaction
update sales.orders set order_status = 2 where order_id = 1

waitfor delay '00:00:05'
update sales.customers set first_name = 'Mark' where customer_id = 1

commit transaction

-- Create a trigger to updates the Stock (quantity) table whenever new order placed in orders tables

create trigger trgUpdateStockOnNewOrderPlaced
on sales.order_items
after insert
as
begin
	declare @store_id int, @product_id int, @quantity int;
    select	@store_id = o.store_id,
			@product_id = i.product_id,
			@quantity = i.quantity
    from inserted i
    inner join sales.orders o
        on i.order_id = o.order_id;

    update production.stocks
    set quantity = quantity - @quantity
    where store_id = @store_id and product_id = @product_id;
end

select * from production.stocks
select * from sales.order_items

insert into sales.orders(customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
values(49,4,'2024-10-23','2024-11-04','2024-10-25',1,5)


--8) Create a trigger to that prevents deletion of a customer if they have existing orders.
create view vwCustomerDetails
as
select 
    customer_id,
    first_name,
    last_name,
    phone,
    email,
    street,
    city,
    state,
    zip_code
from 
    sales.customers
create trigger trgPreventCustomerDeletion
on vwCustomerDetails
instead of delete
as
begin
		declare @customerID int
        select @customerID = o.customer_id
        from sales.orders o
        where o.customer_id in (select customer_id from deleted)
	if(@customerID is not null)
    begin
        raiserror('cannot delete customer with existing orders.', 16, 1);
        rollback;
    end
    else
    begin
        delete from sales.customers
        where customer_id in (select customer_id from deleted);
    end
end

select * from vwCustomerDetails
select * from sales.orders
delete from vwCustomerDetails
where customer_id = 1212
-- assignments 

exec sp_tables 'dbo.Employee'

 
--9) Create Employee,Employee_Audit insert some test data

--	b) Create a Trigger that logs changes to the Employee Table into an Employee_Audit Table
create table Employee_Audit_Test  (    
	ID int identity(1,1),
	empID int,
	audit_action varchar(255),
	audit_date   Date Default GETDATE()
)  

select * from Employee
select * from Employee_Audit_Test

create trigger trgEmployeeInsert
on dbo.Employee
for insert	
as
begin
    insert into Employee_Audit_Test(empID,audit_action,audit_date)
    select EmployeeID ,'INSERT',GETDATE() from inserted
end

insert into Employee values(9,'Arsh','Male','2003-09-11',4)

create trigger trgEmployeeUpdate
on dbo.Employee
after update
as
begin
    insert into Employee_Audit_Test(empID,audit_action,audit_date)
    select EmployeeID ,'UPDATE',GETDATE() from inserted
end

update Employee set DepartmentID = 3 where EmployeeID = 9
 
--10) create Room Table with below columns

--RoomID,RoomType,Availability

create table room (
    roomid int primary key not null,
    roomtype varchar(255) not null,
    [availability] varchar(20) check (availability in ('available', 'unavailable')) not null
)

--create Bookins Table with below columns

--BookingID,RoomID,CustomerName,CheckInDate,CheckInDate
 create table bookings (
    bookingid int primary key not null,
    roomid int not null,
    customername varchar(255) not null,
    checkindate date not null,
    checkoutdate date not null,
    foreign key (roomid) references room(roomid) on delete cascade
)
--Insert some test data with both  the tables
insert into room (roomid, roomtype, [availability]) values
(1, 'single', 'available'),
(2, 'double', 'available'),
(3, 'suite', 'available'),
(4, 'deluxe', 'unavailable')

insert into bookings (bookingid, roomid, customername, checkindate, checkoutdate) values
(1, 1, 'Varun', '2024-10-15', '2024-10-20'),
(2, 2, 'Alisha', '2024-10-18', '2024-10-22')
--Ensure both the tables are having Entity relationship
select * from room
select * from bookings

--Write a transaction that books a room for a customer, ensuring the room is marked as unavailable

begin transaction
if exists (select roomid from room where roomid = 3 and availability = 'available')
begin
	insert into bookings (bookingid, roomid, customername, checkindate, checkoutdate)
    values (4, 3,'Neymar','2024-10-25','2024-11-05');
	update room
    set availability = 'unavailable'
    where roomid = 3;

	print 'room booked successfully.'
end
else
begin
rollback transaction
print 'Room is unavailable'
end
commit transaction