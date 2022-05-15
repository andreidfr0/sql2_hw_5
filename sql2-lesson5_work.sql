-- 2. Подумать, какие операции являются транзакционными, и написать несколько примеров с транзакционными запросами.
--

SET SQL_SAFE_UPDATES = 0;
SET AUTOCOMMIT = 0;

SELECT @b := MIN(`salary`) AS `min_salary` FROM `salaries`;
select @b; -- 'emp_no 500000' 'salary 1345'

-- ex1
begin;
UPDATE `salaries` SET `salary` = @b + 5000 WHERE `salary` = @b;
commit;

select * from salaries where emp_no = 500000;

-- ex2
begin;
insert into employees set
emp_no = 500010,
birth_date = '1900-12-12',
first_name = 'Evgeni',
last_name = 'Popov',
gender = 'm',
hire_date = '9999-01-01'
;
-- begin;
rollback;
-- 

select * from employees 
where last_name = 'popov' and
      first_name = 'Evgeni';
      
-- ex3
select * from employees
where emp_no = (
	select emp_no
	from salaries
    order by salary desc
    limit 1
    )
;
-- '43624', '1953-11-14', 'Tokuyasu', 'Pesch', 'M', '1985-03-26'

--  Удалить одного сотрудника, у которого максимальная зарплата.
start transaction;
delete from employees
where emp_no = (
	select emp_no
	from salaries
    order by salary desc
    limit 1
    )
;      
rollback;
--  мы ошиблись с критерием

select * from employees
where emp_no = (
	select emp_no
	from salaries
    order by salary desc
    limit 1
    )
;

-- 3. Проанализировать несколько запросов с помощью EXPLAIN.
--
-- ex1
-- Выбрать максимальную зарплату у сотрудника.
explain select 
	max(sl.salary) as max_salary,
    CONCAT(COALESCE(emp.FIRST_NAME,''),' ',COALESCE(emp.LAST_NAME,'')) as EMPLOYEE_full_NAME
from salaries sl
	left join employees emp on emp.emp_no = sl.emp_no 
group by EMPLOYEE_full_NAME
order by max_salary desc
;
-- '1', 'SIMPLE', 'sl', NULL, 'ALL', NULL, NULL, NULL, NULL, '2797530', '100.00', 'Using temporary; Using filesort'
-- '1', 'SIMPLE', 'emp', NULL, 'eq_ref', 'PRIMARY', 'PRIMARY', '4', 'employees.sl.emp_no', '1', '100.00', NULL

-- тип запрса SIMPLE, используется индексы EQ_REF при Left Join для связывания

-- ex2
use geodata;
-- Сделать запрос, в котором мы выберем все данные о городе – регион, страна.
explain select
 ci.id AS 'ID',
 ci.country_id AS 'country ID',
 ci.region_id AS 'region ID',
 ci.important AS ' is capital',
 ci.title AS city,
 co.title AS country,
 re.title AS region
from _cities ci
	left join _countries co ON ci.country_id = co.id
    left join _regions re ON ci.region_id = re.id
;

-- тип запроса SIMPLE, используется индексы EQ_REF при Left Join для связывания. запрос оптимален