----------------------------------------------------------------------------------------------------
-- ПРАКТИЧЕСКОЕ ЗАНЯТИЕ 4 --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 1. Вывести самый высокий, самый низкий и средний оклад по всем служащим, а также суммы всех окладов.
--    Назовите столбцы Maximum, Minimum, Average и Sum соответственно.
select 
max(salary) AS "Maximum" 
,min(salary) AS "Minimum"
,avg(salary) AS "Average"
, sum(salary)AS "Sum"
from employees e 
where 1=1;
-- 2. Вывести самый высокий, самый низкий и средний оклад, а также суммы окладов по всем служащим по каждой должности.
--    Назовите столбцы job_id Maximum, Minimum, Average и Sum соответственно.
select 
job_id,
max(salary) AS "Maximum" 
,min(salary) AS "Minimum"
,avg(salary) AS "Average"
, sum(salary)AS "Sum"
from employees e 
where 1=1
group by job_id;
-- 3. Напишите запрос для вывода должности и количества служащих, занимающих каждую должность.
--    Назовите столбцы job_id и count соответственно.
select 
job_id,
count(*) as "count"
from employees e 
where 1=1
group by job_id;
-- 4. Получите количество служащих, имеющих подчиненных, без их перечисления.
--    Столбец назовите Number Of Managers
--    Подсказка: используйте столбец manager_id
select  
count (distinct manager_id) as "Number Of Managers"
from employees e 
where 1=1
and manager_id is not null;
-- 5. Напишите запрос для вывода разности между самым высоким и самым низким окладами
--    Назовите столбец difference
select 
max(salary) - min(salary) AS "difference"
from employees e 
where 1=1;
-- 6.* Напишите запрос для вывода номера каждого менеджера и заработной платы самого низкооплачиваемого
--     из его подчиненных. Исключите всех, для которых неизвестныих менеджеры. Исключите все группы, где
--     минимальный оклад составляет менее 6000. Отсортируйте выходные строки в порядке убывания оклада.
--     Столбцы назовите manager_id и min_salary
select 
distinct manager_id as "manager_id",
min(salary) as "min_salary"
from employees e 
where 1=1
and manager_id is not null
group by manager_id
having min(salary)>6000
order by min(salary) desc;
-- 7.* Напишите запрос для вывода общего количества служащих и количества служащих, нанятых в 1995, 1996,
--     1997 и 1998 годах. Столбцы назовите Total,1995, 1996, 1997, 1998.
--     Подсказка: для получения года из даты используйте функцию extract('Year' from hire_date)
select 
count(job_id) as "Total",
sum( case extract('Year' from hire_date) when 1995 then 1 else 0 end) as "1995",
sum( case extract('Year' from hire_date) when 1996 then 1 else 0 end) as "1996",
sum( case extract('Year' from hire_date) when 1997 then 1 else 0 end) as "1997",
sum( case extract('Year' from hire_date) when 1998 then 1 else 0 end) as "1998"
from employees e 
where 1=1;
-- 8.* Напишите матричный запрос для вывода всех должностей и суммы заработной платы служащих, работающих 
--     в этой должности в отделах 20, 50, 80 и 90. Последний столбец должен содержать сумму заработной платы
--     служащих этих отделов, занимающих каждую конкретную должность. Дайте столбцам соответствующие заголовки.
--     Столбцы назовите Job, Dept20, Dept50, Dept80, Dept90, Total.
select 
job_id as "Job",
sum(case department_id when 20 then salary else 0 end) as "Dept20",
sum(case department_id when 50 then salary else 0 end) as "Dept50",
sum(case department_id when 80 then salary else 0 end) as "Dept80",
sum(case department_id when 90 then salary else 0 end) as "Dept90",
sum(salary) as "Total"
from employees e 
where 1=1
and department_id in (20,50,80,90)
group by job_id;