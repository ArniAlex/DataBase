--1--
-- Найти всех участников контестов от 03.11.2025 мужского пола, которым уже исполнилось 18 лет. 
SELECT p.* 
FROM participant p
JOIN solution s ON p.id = s.participant_id 
JOIN contest_info c ON s.contest_id = c.id
WHERE p.gender = TRUE AND c.date = '2025-11-03' AND EXTRACT(YEAR FROM AGE('2025-11-03', p.birth_date)) >= 18;

--2--
-- Найти все задачи, в описании которых присутствуют подстроки “переменная” и “значение”.
SELECT * EXCEPT 
FROM task t
WHERE t.task_description LIKE '%переменная%' AND t.task_description LIKE '%значение%';

--3--
--Найти фамилии, имена и возраст (кол-во полных лет) всех участников, участвовавших хотя бы в трёх контестах.
SELECT 
    p.last_name,
    p.first_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date)) AS age,
    COUNT(DISTINCT s.contest_id) as contest_count
FROM participant p
JOIN solution s ON p.id = s.participant_id
GROUP BY p.id, p.last_name, p.first_name, p.birth_date
HAVING COUNT(DISTINCT s.contest_id) >= 3;

--4--
--Найти все задачи, которые были хотя бы раз решены на высший балл (100).
SELECT DISTINCT t.*
FROM task t
JOIN solution s ON t.contest_id = s.contest_id AND t.task_id = s.task_id
WHERE s.score = 100;

--5--
--Найти все задачи, которые ни разу не были решены хотя бы на 52 балла на языке программирования “Py***n”.
SELECT t.*
FROM task t
WHERE (t.contest_id, t.task_id) NOT IN (
    SELECT contest_id, task_id 
    FROM solution 
    WHERE score >= 52
      AND programming_language LIKE 'Py%n'
);

--6--
--Найти все названия контестов, которые проводились летом.
SELECT c.name 
FROM contest_info c
WHERE EXTRACT(MONTH FROM c.date) BETWEEN 6 AND 8;

--7--
--Найти все пары, состоящие из языка программирования и его версии, на которых были решены хотя бы две задачи на 85 баллов и выше. 
SELECT 
    s.programming_language,
    s.language_version,
    COUNT(DISTINCT s.contest_id || '_' || s.task_id) as tasks_count
FROM solution s
WHERE s.score >= 85
GROUP BY s.programming_language, s.language_version
HAVING COUNT(DISTINCT s.contest_id || '_' || s.task_id) >= 2;

--8--
--Найти все задачи, в решении которых на языке программирования “C” версии “C99” используется инструкция “#include <string.h>”. 
SELECT DISTINCT
    t.contest_id,
    t.task_id,
    t.task_name
FROM task t
JOIN solution s ON t.contest_id = s.contest_id AND t.task_id = s.task_id
WHERE s.programming_language = 'C'
  AND s.language_version = 'C99'
  AND s.solution_text LIKE '%#include <string.h>%';

--9--
--Найти контесты, в которых хотя бы три участника решили все задачи на одном и том же языке программирования одной и той же версии, средний балл за которые превышает 75 и 
--ни одна задача не решена менее чем на 50 баллов. 
SELECT 
    s.contest_id,
    ci.name as contest_name,
    s.programming_language,
    s.language_version,
    COUNT(DISTINCT s.participant_id) as participants_count
FROM solution s
JOIN contest_info ci ON s.contest_id = ci.id
JOIN (
    SELECT 
        s1.contest_id,
        s1.participant_id,
        s1.programming_language,
        s1.language_version
    FROM solution s1
    GROUP BY s1.contest_id, s1.participant_id, s1.programming_language, s1.language_version
    HAVING COUNT(DISTINCT s1.task_id) = (
        SELECT COUNT(DISTINCT task_id) 
        FROM task t 
        WHERE t.contest_id = s1.contest_id
    )
) AS full_solvers ON s.contest_id = full_solvers.contest_id 
                  AND s.participant_id = full_solvers.participant_id
                  AND s.programming_language = full_solvers.programming_language
                  AND s.language_version = full_solvers.language_version
WHERE s.score >= 50 
GROUP BY s.contest_id, ci.name, s.programming_language, s.language_version
HAVING 
    COUNT(DISTINCT s.participant_id) >= 3
    AND AVG(s.score) > 75
    AND MIN(s.score) >= 50; 

--10--
-- Найти все языки программирования, которые использовались в контесте с названием “поставьте 3 плиз”.
SELECT DISTINCT s.programming_language
FROM solution s
JOIN contest_info ci ON s.contest_id = ci.id
WHERE ci.name = 'поставьте 3 плиз';

--11--
-- Найти всех участников контеста с названием “памагити((9(9”, которые решили все задачи контеста минимум на 45 баллов, и все задачи решены на разных языках 
--программирования, либо на разных версиях одного и того же языка программирования. 
SELECT 
    p.id,
    p.last_name,
    p.first_name
FROM participant p
WHERE p.id IN (
    SELECT s.participant_id
    FROM solution s
    JOIN contest_info ci ON s.contest_id = ci.id
    WHERE ci.name = 'памагити((9(9'
      AND s.score >= 45
    GROUP BY s.participant_id
    HAVING 
        COUNT(DISTINCT s.task_id) = (
            SELECT COUNT(DISTINCT task_id) 
            FROM task t 
            WHERE t.contest_id = s.contest_id
        )
        AND COUNT(DISTINCT s.programming_language) = COUNT(DISTINCT s.task_id)
        AND COUNT(DISTINCT s.language_version) = COUNT(DISTINCT s.task_id)
);

--12--
-- Найти всех девушек, решивших хотя бы 3 задачи любого одного контеста на 52 балла и выше. 
SELECT 
    p.id,
    p.last_name,
    p.first_name,
    p.birth_date,
    s.contest_id,
    ci.name as contest_name,
    COUNT(DISTINCT s.task_id) as tasks_solved
FROM participant p
JOIN solution s ON p.id = s.participant_id
JOIN contest_info ci ON s.contest_id = ci.id
WHERE p.gender = FALSE
  AND s.score >= 52
GROUP BY p.id, p.last_name, p.first_name, p.birth_date, s.contest_id, ci.name
HAVING COUNT(DISTINCT s.task_id) >= 3;

--13--
-- Найти всех участников с фамилией “Демченко”, решивших все задачи контеста “no way 
--back” от 03.11.2025 на 0 баллов, причём все задачи этого контеста были написаны им на 
--языке программирования с названием “C++” и хотя бы в одном тексте решения 
--присутствует подстрока “unsigned double”.
SELECT 
    p.id,
    p.last_name,
    p.first_name
FROM participant p
WHERE p.last_name = 'Демченко'
  AND p.id IN (
      SELECT s.participant_id
      FROM solution s
      JOIN contest_info ci ON s.contest_id = ci.id
      WHERE ci.name = 'no way back'
        AND ci.date = '2025-11-03'
        AND s.score = 0
        AND s.programming_language = 'C++'
      GROUP BY s.participant_id
      HAVING COUNT(DISTINCT s.task_id) = (
          -- Общее количество задач в контесте
          SELECT COUNT(DISTINCT task_id)
          FROM task t
          JOIN contest_info ci2 ON t.contest_id = ci2.id
          WHERE ci2.name = 'no way back'
            AND ci2.date = '2025-11-03'
      )
  )
  AND p.id IN (
      SELECT s2.participant_id
      FROM solution s2
      JOIN contest_info ci3 ON s2.contest_id = ci3.id
      WHERE ci3.name = 'no way back'
        AND ci3.date = '2025-11-03'
        AND s2.solution_text ILIKE '%unsigned double%'
  );

--14--
-- Найти все задания со средней оценкой от 80 до 85 баллов среди всех его(~задания) решений хотя бы на 70 баллов.
SELECT 
    t.contest_id,
    t.task_id,
    t.task_name,
    AVG(s.score) as average_score,
    COUNT(s.participant_id) as solutions_count
FROM task t
JOIN solution s ON t.contest_id = s.contest_id AND t.task_id = s.task_id
WHERE s.score >= 70
GROUP BY t.contest_id, t.task_id, t.task_name
HAVING AVG(s.score) BETWEEN 80 AND 85;

--15--
--Найти все задания, любой комментарий проверяющего которых содержит подстроку “где лабы?”.
SELECT DISTINCT
    t.contest_id,
    t.task_id,
    t.task_name,
    s.reviewer_comment
FROM task t
JOIN solution s ON t.contest_id = s.contest_id AND t.task_id = s.task_id
WHERE s.reviewer_comment ILIKE '%где лабы?%';
