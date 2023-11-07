-- 3.1. Напишите запрос для вывода текущей даты. Назовате столбец Date.
select now() as Date;
-- 3.2. Вывести номер служащего, его фамилию, оклад и новый оклад, повышенный на 15.5% и округленный до целого.
--      Столбец, содержащий новый оклад, должен иметь имя New Salary.
select employee_id ,last_name ,salary , round(salary * 1.155, 0)  as "New Salary" from employees e order by employee_id;
-- 3.3. В запрос к предыдущему заданию добавьте столбец, который будет содержать результат вычитания
--      старого оклада из нового. Назовите столбец Increase.
select employee_id,
last_name ,
salary , 
round(salary * 1.155, 0) as "New Salary" ,
round(salary * 1.155, 0) - salary as "Increase"
from employees e 
order by employee_id;
-- 3.4. Выведите фамилии служащих (первая буква фамилии должна быть заглавной, а остальные - строчными)
--      и длину каждой фамилии для тех служащих, фамилия которых начинается с символа J, A или M.
--      Столбцы назовите Name и Length соответственно. Отсортируйте результат по фамилиям служащих.
select 
initcap(last_name) as "Name",
length(last_name) as "Length"
from employees e 
where 1=1
and ((position('J' in last_name) !=0) or (position('A' in last_name) !=0)  or (position('M' in last_name) !=0) )
order by last_name;
-- 3.5. Для каждого служащего выведите фамилию, дату найма и год найма (назовите hire_year).
select 
last_name,
hire_date ,
extract('year' from hire_date) as "hire_year"
from employees e 
where 1=1;
-- 3.6. Вывести по каждому служащему отчет в следующем виде:
--      <фамилия> зарабатывает <оклад> в месяц, но желает <утроенный оклад>.
--      Назовите столбец Dream Salaries.
--      Для преобразования числа в текст используйте функцию to_char(salary, 'FM999999999999999999')
select concat(last_name, ' зарабатывает ',to_char(salary, 'FM999999999999999999'),' в месяц, но желает ',to_char(salary*3, 'FM999999999999999999'))  as "Dream Salaries"
from employees e 
where 1=1;
-- 3.7. Вывести фамилии и оклады всех служащих. Столбец с окладом назовите Salary. Длина столбца должна быть 
--      15 символов с дополненными слева символами $.
--      Для преобразования числа в текст используйте функцию to_char(salary, 'FM999999999999999999')
select 
last_name,
lpad(to_char(salary, 'FM999999999999999999'), 15, '$')
--, to_char(salary, 'FMLLLLLLLLD') as "Salary"
from employees e 
where 1=1;
-- 3.8.* Вывести фамилии и суммы комиссионных каждого служащего. Если служащий не зарабатывает комиссионных, 
--       укажите в столбце "No Commission". Назовите столбец Comm.
--       Для преобразования числа в текст используйте функцию to_char с маской 'FM999999999999999999D00'
select 
last_name,
COALESCE(to_char(commission_pct, 'FM999999999999999999D00'),'No Commission') as "Comm"
from employees e 
where 1=1;
-- 3.9.* Выведите первые восемь букв фамилии сотрудников, затем пробел, затем заработную плату в виде гистограммы, 
--       состоящей из звездочек, где каждая звездочка означает $1000. 
--       Пример: King ************************
--       Результат отсортируйте по убыванию заработной платы.
--       Результат должен быть выведен одним столбцом, озаглавленным как employees_and_their_salaries
--       Для вычисления потребуется явное преобразование типа в целое число, используйте salary::int 
select 
concat(left(last_name,8),' ',lpad(' ', round(salary/1000)::int, '*'))
from employees e 
where 1=1
order by salary DESC;
-- 3.10.* Используя оператор CASE, напишите запрос для отображения должности сотрудника и ее разряда (grade),
--        строки не должны повторяться.
--        Соответствие типа должности job_id:
--        AD_PRES A
--        ST_MAN   B
--        IT_PROG  C
--        SA_REP   D
--        ST_CLERK E
--        Другая   0
select distinct 
job_id,
case job_id
	when 'AD_PRES' then 'A'
	when 'ST_MAN' then 'B'
	when 'IT_PROG' then 'C'
	when 'SA_REP' then 'D'
	when 'ST_CLERK' then 'E'
	else '0'
	end as "grade"
 from employees e;