-- 1.4. Получить данные о всех должностях из таблицы employees
select distinct job_id from public.employees;
-- 1.5. Получить данные о всех сотрудниках и идентификаторах их должностей.
-- Нужно вывести фамилию, соединенное с идентификатором должности через запятую и пробел.
-- Назвать столбец Employee and Title;
SELECT last_name || ', ' || job_id AS "Employee and Title" from public.employees;
-- 2.1. Вывести фамилии(last_name) и оклады(salary) служащих, получающих более 12000
select last_name,salary from public.employees where salary >12000;
-- 2.2. Вывести фамилию(last_name) и номер отдела(department_id) служащего под номером 176
select last_name,department_id from public.employees where employee_id=176;
-- 2.3. Вывести фамилии(last_name) и оклады(salary) всех служащих, чей оклад не входит в диапазон от 5000 до 12000
select last_name,salary from public.employees where salary not BETWEEN 5000 and 12000;
-- 2.4. Вывести фамилию(last_name), идентификатор должности (job_id) и дату найма (hire_date)
--      всех служащих с фамилиями Matos и Taylor. Отсортируйте данные в порядке возрастания даты найма.
select last_name,job_id,hire_date from public.employees where last_name in ('Matos','Taylor') order by hire_date;
-- 2.5. Вывести фамилию(last_name) и номер отдела(department_id) всех служащих из отделов 20 и 50.
--      Отсортируйте данные по фамилиям в алфавитном порядке.
select last_name,department_id from public.employees where employees.department_id in (20,50) order by last_name;
-- 2.6. Вывести фамилии(last_name) и оклады(salary) служащих отделов 20 и 50, зарабатывающих от 5000 до 12000.
--      Назовите столбцы Employee и Monthly Salary, соответственно.
select em.last_name as Employee,salary as "Monthly Salary" from public.employees as em
                                      where em.department_id in (20,50)
                                      and em.salary BETWEEN 5000 and 12000;
-- 2.7. Вывести фамилии(last_name) и даты найма(hire_date) всех служащих, нанятых в 1994 году.
select em.last_name,em.hire_date from public.employees as em
                                      where date_part('year',em.hire_date)=1994;
-- 2.8. Вывести фамилии(last_name) и должности(job_id) всех служащих, не имеющих менеджера.
select em.last_name,em.job_id from public.employees as em
                                      where em.manager_id is null;
-- 2.9. Вывести фамилии(last_name), оклады(salary) и комиссионные всех служащих, зарабатывающих комиссионные.
--      Отсортируйте данные в порядке убывания окладов и комиссионных.
select em.last_name,em.salary,em.commission_pct from public.employees as em
                                      where em.commission_pct is not null
                                      order by em.salary desc,em.commission_pct desc;
-- 2.10. Вывести все фамилии служащих, в которых третья буква - a
select em.last_name from public.employees as em
                                      where position('a' in em.last_name)=3;
-- 2.11. Вывести все фамилии служащих, в которых есть буквы a и e
select em.last_name from public.employees as em
                                      where 1=1
                                      --and em.last_name like '??a%'
                                      and position('a' in em.last_name) !=0
                                      and position('e' in em.last_name) !=0;

--select md5 ('a');
--select md5 ('а');
-- 2.12. Вывести фамилии, должности и оклады всех служащих, работающих торговыми представителями (SA_REP)
--       или клерками на складе (ST_CLERK), у которых оклад не равен 2500, 3500, 7000
select em.last_name,em.job_id,em.salary from public.employees as em
                                      where 1=1
                                      and em.job_id in ('SA_REP','ST_CLERK') and em.salary not in (2500, 3500, 7000);
-- 2.13. Вывести фамилии, оклады и комиссионные всех служащих, у которых сумма комиссионных составляют 20%.
select em.last_name,em.salary,em.commission_pct from public.employees as em
                                      where 1=1
                                      and em.commission_pct=0.2;