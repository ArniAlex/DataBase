	-- 1 --
SELECT * 
FROM students s 
JOIN groups g ON s.group_id = g.id
WHERE g.course = 3;

	-- 2 --
SELECT g.cipher 
FROM groups g 
JOIN students s ON g.id = s.group_id
GROUP BY g.cipher
HAVING COUNT(*) >= 10;

	--3--
SELECT s.name 
FROM subjects s 
JOIN marks m ON s.id = m.subj_id
WHERE m.semester_num = 4
GROUP BY s.name 
HAVING AVG(m.grade) > 3.5;

	--4--
SELECT s.surname, s.first_name
FROM students s 
JOIN marks m ON  s.id = m.stud_id
JOIN subjects sj ON  m.subj_id = sj.id 
WHERE sj.report_type = 'exam' AND m.semester_num = 3
GROUP BY s.surname, s.first_name 
HAVING AVG(m.grade) = 5 
LIMIT 10;

	--5--
SELECT DISTINCT sj.name
FROM subjects sj
JOIN marks m ON m.subj_id = sj.id 
WHERE m.semester_num BETWEEN 5 AND 8 AND sj.report_type = 'paper';

	--6--
SELECT semester_num
FROM (
    SELECT 
        m.semester_num,
        m.stud_id
    FROM marks m 
    JOIN subjects sj ON m.subj_id = sj.id
    JOIN students s ON m.stud_id = s.id
    JOIN groups g ON s.group_id = g.id 
    WHERE sj.report_type = 'exam' AND g.cipher = 'ИТПМ-124'
    GROUP BY m.semester_num, m.stud_id
    HAVING AVG(m.grade) > 4.5
) student_semester_avgs
GROUP BY semester_num
HAVING COUNT(stud_id) >= 3;

	--7--
SELECT s.surname, s.first_name
FROM students s 
JOIN groups g ON s.group_id = g.id 
WHERE s.gender = 'm' AND g.course IN (2,4)
ORDER BY s.birth_date
LIMIT 5;

	--8--
SELECT sj.name
FROM subjects sj
JOIN marks m ON m.subj_id = sj.id
JOIN students s ON m.stud_id = s.id
JOIN  groups g ON s.group_id = g.id 
WHERE g.cipher = 'ИТПМ-124'
GROUP BY sj.name
HAVING AVG(m.grade) BETWEEN 3.0 AND 4.0;

	--9--
SELECT s.surname 
FROM students s 
JOIN marks m ON s.id = m.stud_id 
JOIN subjects sj ON m.subj_id = sj.id 
WHERE sj.name = 'Базы данных' AND m.semester_num = 3 AND m.grade = 2;

	--10--
SELECT s.surname, s.first_name
FROM students s 
JOIN marks m ON s.id = m.stud_id 
JOIN subjects sj ON m.subj_id = sj.id
WHERE sj.report_type = 'paper' AND sj.name = 'Защита информации' AND m.semester_num = 4;

	--11--
SELECT DISTINCT s.surname, s.first_name
FROM students s 
JOIN marks m ON s.id = m.stud_id 
JOIN subjects sj ON m.subj_id = sj.id
WHERE sj.report_type = 'exam' AND m.grade = 2;

	--12--
SELECT DISTINCT g.cipher
FROM groups g 
JOIN students s ON g.id = s.group_id 
JOIN marks m ON s.id = m.stud_id 
JOIN subjects sj ON m.subj_id = sj.id
WHERE sj.report_type = 'paper' AND m.grade = 2;

	--13--
SELECT sj.name 
FROM subjects sj
JOIN marks m ON sj.id = m.subj_id 
JOIN students s ON m.stud_id = s.id
WHERE m.grade = 2
  AND s.id IN (
    SELECT stud_id
    FROM marks
    WHERE grade = 2
    GROUP BY stud_id
    HAVING COUNT(DISTINCT subj_id) > 1
  )
GROUP BY sj.id, sj.name;

	--14--
SELECT s.surname, s.first_name, AVG(m.grade) as average_grade
FROM students s
JOIN groups g ON s.group_id = g.id 
JOIN marks m ON s.id = m.stud_id
WHERE g.cipher = 'ИТПМ-124' AND m.semester_num = 3
GROUP BY s.surname, s.first_name 
ORDER BY average_grade DESC;

	--15--
SELECT AVG(m.grade)
FROM marks m 
JOIN subjects sj ON m.subj_id = sj.id 
JOIN students s ON m.stud_id = s.id 
WHERE sj.name = 'Дифференциальные уравнения' AND s.first_name = 'Давид' AND sj.report_type = 'exam';

	--16--
SELECT s.surname, s.first_name, AVG(m.grade) as average_grade
FROM marks m 
JOIN students s ON m.stud_id = s.id
WHERE s.first_name LIKE '%Степан%'
GROUP BY s.surname, s.first_name;

	--17--
SELECT sj.name, g.cipher
FROM subjects sj
JOIN marks m ON sj.id = m.subj_id
JOIN students s ON m.stud_id = s.id
JOIN groups g ON s.group_id = g.id
WHERE m.grade = 2
GROUP BY sj.name, g.cipher
HAVING COUNT(*) >= (
    SELECT COUNT(DISTINCT s2.id) * 0.5
    FROM students s2
    JOIN groups g2 ON s2.group_id = g2.id
    WHERE g2.cipher = g.cipher
);

	--18--
SELECT sj.name
FROM subjects sj
JOIN marks m ON m.subj_id = sj.id 
WHERE sj.report_type = 'rating' AND m.grade = 2
GROUP BY sj.name
HAVING COUNT(DISTINCT m.stud_id) >= 5;

	--19--
SELECT sj.name, AVG(m.grade)
FROM students s 
JOIN marks m ON s.id = m.stud_id 
JOIN subjects sj ON m.subj_id = sj.id 
WHERE s.id NOT IN (
    SELECT DISTINCT stud_id 
    FROM marks 
    WHERE grade = 2
)
GROUP BY sj.name;

	--20--
SELECT DISTINCT s.surname, s.first_name
FROM students s
WHERE s.id IN (
    SELECT stud_id
    FROM marks
    WHERE semester_num = 3 AND grade >= 3
    GROUP BY stud_id
)
AND s.id IN (
    SELECT stud_id
    FROM marks
    WHERE semester_num IN (1, 2) AND grade = 2
    GROUP BY stud_id
);

