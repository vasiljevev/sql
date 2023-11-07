----------------------------------------------------------------------------------------------------
-- ПРАКТИЧЕСКОЕ ЗАНЯТИЕ 5 --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 1. Вывести адреса всех отделов. Используйте таблицы locations и countries. 
--    Вывести код локации (location_id), адрес (street_address), город (city), регион (state_province) и страну (country_name).
select location_id , street_address ,city ,state_province,country_name  from locations l 
	inner join countries c 
		on l.country_id =c.country_id;
-- 2. Вывести фамилию (last_name), номер отдела (department_id) и название отдела (department_name) для всех сотрудников.
select e.last_name ,e.department_id,d.department_name  from employees e 
	inner join departments d 
		on d.department_id =e.department_id ;
-- 3. Напишите запрос для вывода фамилии, должности, номера отдела и названия отдела всех служащих, работающих в городе Toronto.
select e.last_name ,j.job_title ,e.department_id,d.department_name  from employees e
	inner join jobs j 
		on j.job_id =e.job_id 
	inner join departments d 
		on d.department_id =e.department_id
	inner join locations l 
		on l.location_id =d.location_id 
	where l.city = 'Toronto';
-- 4. Выведите фамилии и номера служащих вместе с фамилиями и номерами их менеджеров.
--    Назовите столбцы: Employee, Emp#, Manager, Mgr#
select 
e.last_name as "Employee"
,e.employee_id  as "Emp#"
,e2.last_name as "Manager"
,e2.employee_id  as "Mgr#"
from employees e 
inner join employees e2 
on e.manager_id =e2.employee_id ;

-- 5. Измените запрос задания 4 так, чтобы в выборке были и сотрудники, не имеющие менеджера.
--    Упорядочьте результат по возрастанию номера служащего.
select 
e.last_name as "Employee"
,e.employee_id  as "Emp#"
,e2.last_name as "Manager"
,e2.employee_id  as "Mgr#"
from employees e 
left join employees e2 
on e.manager_id =e2.employee_id 
order by e.employee_id ;
-- 6. Вывести номер отдела, фамилию служащего и фамилии всех служащих, работающих в одном отделе с данным служащим.
--    Назовите столбцы: department, employee, colleague.
select 
e.department_id as "department"
,e.last_name as "employee"
, e2.last_name  as "colleague"
from employees e 
	left join (
				select department_id ,last_name,employee_id   from employees 
				order by department_id 
				
				) as e2
				on e.department_id=e2.department_id
				where e2.employee_id <> e.employee_id
			order by e.department_id, e.employee_id;
-- 7. Выведите фамилию, должность, название отдела, оклада и категорию (grade_level), 
--    столбцы назовите соответственно: last_name, job_id, department_name, salary, gra.
select  e.last_name, e.job_id ,d.department_name , e.salary, jg.grade/*, jg.lowest_sal , jg.highest_sal */ from employees e 
	inner join departments d 
		on d.department_id = e.department_id 
	left join job_grades jg 
		on jg.lowest_sal <= e.salary and jg.highest_sal >=e.salary 
	order by e.salary desc;
-- 8*. Вывести фамилию и дату найма служащих нанятых после Davies.
select e.last_name , e.hire_date  from employees e 
	inner join (select hire_date from employees e2 where last_name = 'Davies' limit 1) as e3
	on e.hire_date > e3.hire_date
	order by e.hire_date desc;
-- 9*. Вывести сведения о служащих, нанятых раньше своих менеджеров. 
--     Нужно вывести фамилию, дату найма, а также фамилию и дату найма их менеджеров.
select 
e.last_name as "Employee"
,e.hire_date  as "Emp_hire_date"
,e2.last_name as "Manager"
,e2.hire_date  as "Mgr_hire_date"
from employees e 
	inner join employees e2 
	on e.manager_id =e2.employee_id 
	and e.hire_date < e2.hire_date;