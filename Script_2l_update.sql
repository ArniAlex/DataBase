TRUNCATE TABLE issuance, booking, book_instance, reader, book, publishing_house, author RESTART IDENTITY CASCADE;
DROP VIEW IF EXISTS available_books_summary, overdue_books, books_issues;

--1-- 

INSERT INTO author (surname, name)
VALUES  ('Брэдбери','Рэй'),
		('Кинг','Стивен'),
		('Булгаков','Михаил'),
		('Оруэлл','Джордж'),
		('Набоков','Владимир'),
		('Толстой', 'Лев')
RETURNING id;

UPDATE author
SET surname = 'Макиавелли', name = 'Никколо'
WHERE id = 5;
UPDATE author
SET surname = 'Лавкрафт', name = 'Говард'
WHERE id = 4;

DELETE FROM author 
WHERE id IN (5, 6);


	--2--

INSERT INTO publishing_house (name, town)
VALUES  ('АСТ','Москва'),
		('Росмэн','Москва'),
		('Феникс','Санкт-Петербург')
RETURNING id;

UPDATE publishing_house 
SET name = 'Эксмо'
WHERE id = 2; 

DELETE FROM publishing_house 
WHERE id = 3; 


	--3--

INSERT INTO book (name, author_id, publishing_house_id, version_publishing, year_of_publishing, circulation)
VALUES  ('Зов Ктулху', 4, 1, 2, 2023, 5),
		('Вино из одуванчиков', 1, 1, 3, 2024, 3),
		('Марсианские хроники', 1, 1, 1, 2021, 1),
		('Собачье сердце', 3, 2, 4, 2023, 4),
		('Зеленая миля', 2, 1, 1, 2020, 7),
		('Оно', 2, 2, 3, 2022, 6),
		('Стрелок. Темная башня', 2, 2, 1, 2025, 3)
RETURNING id;

UPDATE book 
SET publishing_house_id = 1
WHERE id = 6; 

DELETE FROM book
WHERE id = 7;


	--4--

INSERT INTO reader (surname, name, date_of_birth, gender, registration_daye)
VALUES  
    ('Кулагин', 'Петр', '1995-05-06', 'M', '2024-11-15'),
    ('Кузнецов','Евгений','1990-08-12', 'M', '2024-10-20'),
    ('Иванова', 'Мария', '1988-03-25', 'W', '2024-09-10'),
    ('Петрова', 'Анна', '1992-11-30', 'W', '2024-12-01')
RETURNING card_number; 

UPDATE reader
SET name = 'Василий'
WHERE card_number = 2;

DELETE FROM reader 
WHERE card_number = 4;


	--5--
INSERT INTO book_instance (information, state, status, location_)
VALUES  
    (1, 'отличное', 'в наличии', '/1/1/1'),
    (2, 'утеряна', 'в наличии', '/1/1/2'), 
    (3, 'удовлетворительное', 'в наличии', '/1/2/1'),
    (4, 'отличное', 'в наличии', '/2/1/1'),
    (5, 'хорошее', 'в наличии', '/2/1/2'),
    (6, 'отличное', 'в наличии', '/2/2/1')
RETURNING inventory_number;

UPDATE book_instance 
SET status = 'выдана'
WHERE inventory_number = 1; 

DELETE FROM book_instance  
WHERE inventory_number = 2;

	--6--

SELECT * FROM reader
WHERE card_number = 3;

SELECT 	b.name,
		a.surname,
		bi.state,
		bi.location_,
		bi.inventory_number
FROM book b
JOIN book_instance bi ON b.id = bi.information
JOIN author a ON b.author_id = a.id
WHERE bi.status = 'в наличии' AND b.name = 'Зеленая миля' AND (bi.state = 'удовлетворительное' OR bi.state = 'хорошее' OR bi.state = 'отличное'); 

UPDATE book_instance 
SET status = 'выдана'
WHERE inventory_number = 5;

UPDATE book 
SET circulation = 6
WHERE name = 'Зеленая миля';

INSERT INTO issuance (card_number, inventory_number, issue_date, expected_return_date, actual_return_date)
VALUES (3, 5, '2025-09-15', '2025-10-06', NULL);


	--7--

UPDATE issuance 
SET actual_return_date = '2025-10-06'
WHERE card_number = 3 AND inventory_number = 5 AND actual_return_date IS NULL;

UPDATE book_instance 
SET status = 'в наличии'
WHERE inventory_number = 5;

UPDATE book 
SET circulation = 7
WHERE name = 'Зеленая миля';


	--8--

CREATE VIEW books_issues AS 
SELECT  r.surname || ' ' || r.name AS "читатель", 
		a.surname || ' ' || a.name AS "автор",
		b.name AS "книга",
		bi.state AS "состояние",
		i.issue_date AS "дата_выдачи"
FROM book b 
JOIN author a ON b.author_id = a.id
JOIN book_instance bi ON b.id = bi.information
JOIN issuance i ON bi.inventory_number = i.inventory_number
JOIN reader r ON r.card_number = i.card_number
WHERE i.actual_return_date IS NULL;


	--9--

CREATE VIEW overdue_books AS
SELECT 
    r.surname || ' ' || r.name AS "читатель",
    a.surname || ' ' || a.name AS "автор", 
    b.name "название книги",
    CURRENT_DATE - i.expected_return_date AS "время просрочки"
FROM issuance i
JOIN reader r ON i.card_number = r.card_number
JOIN book_instance bi ON i.inventory_number = bi.inventory_number
JOIN book b ON bi.information = b.id
JOIN author a ON b.author_id = a.id
WHERE i.actual_return_date IS NULL
AND i.expected_return_date < CURRENT_DATE;


	--10--

SELECT EXISTS(
    SELECT * FROM overdue_books 
    WHERE читатель = 'Кузнецов Василий'
) AS имеет_просрочку;

-- проверить просрочку 

SELECT * FROM reader
WHERE card_number = 2;

SELECT 	b.name,
		a.surname,
		bi.state,
		bi.location_,
		bi.inventory_number
FROM book b
JOIN book_instance bi ON b.id = bi.information
JOIN author a ON b.author_id = a.id
WHERE bi.status = 'в наличии' AND b.name = 'Собачье сердце' AND (bi.state = 'удовлетворительное' OR bi.state = 'хорошее' OR bi.state = 'отличное'); 

UPDATE book_instance 
SET status = 'выдана'
WHERE inventory_number = 4;

UPDATE book 
SET circulation = 3
WHERE name = 'Собачье сердце';

INSERT INTO issuance (card_number, inventory_number, issue_date, expected_return_date, actual_return_date)
VALUES (3, 4, '2025-09-12', '2025-10-10', NULL);


	--11--

SELECT * FROM reader WHERE card_number = 2;

SELECT 	b.name,
		a.surname,
		bi.state,
		bi.location_,
		bi.inventory_number
FROM book b
JOIN book_instance bi ON b.id = bi.information
JOIN author a ON b.author_id = a.id
WHERE bi.status = 'в наличии' AND b.name = 'Собачье сердце' AND (bi.state = 'удовлетворительное' OR bi.state = 'хорошее' OR bi.state = 'отличное'); 

UPDATE book_instance 
SET status = 'забронирована'
WHERE inventory_number = 4;

INSERT INTO booking (card_number, book_id, min_condition_level, booking_datetime)
VALUES (2, 4, 'хорошее', CURRENT_TIMESTAMP);


	--12--

--если прошло больше трех дней 

SELECT 
	r.surname || ' ' || r.name,
	b.name,
	bk.booking_datetime,
	bk.booking_number
FROM booking bk
JOIN reader r ON bk.card_number = r.card_number
JOIN book b ON bk.book_id = b.id
WHERE r.name = 'Василий' AND r.surname = 'Кузнецов' AND b.name = 'Собачье сердце' AND bk.booking_datetime >= CURRENT_TIMESTAMP - INTERVAL '3 days';


DELETE FROM booking
WHERE booking_number = 1;

UPDATE book_instance 
SET status = 'в наличии'
WHERE inventory_number = 4;

	--13--

SELECT EXISTS(
    SELECT * 
    FROM booking bk
    JOIN reader r ON bk.card_number = r.card_number
    JOIN book b ON bk.book_id = b.id
    JOIN book_instance bi ON b.id = bi.information 
    WHERE bi.inventory_number = 4
    AND bk.card_number != 2 
    AND bk.booking_datetime >= CURRENT_TIMESTAMP - INTERVAL '3 days'
);

--если false

SELECT * FROM reader WHERE card_number = 2;

SELECT 
    b.name,
    a.surname,
    bi.state,
    bi.location_,
    bi.inventory_number
FROM book b
JOIN book_instance bi ON b.id = bi.information 
JOIN author a ON b.author_id = a.id
WHERE bi.inventory_number = 4
AND bi.status = 'в наличии';

UPDATE book_instance 
SET status = 'выдана'
WHERE inventory_number = 4;

INSERT INTO issuance (card_number, inventory_number, issue_date, expected_return_date, actual_return_date)
VALUES (2, 4, CURRENT_TIMESTAMP, CURRENT_DATE + INTERVAL '14 days', NULL);


	--14--

CREATE OR REPLACE FUNCTION book_location(book_name VARCHAR)
RETURNS TABLE (
    название_книги VARCHAR,
    автор VARCHAR,
    состояние book_state,
    местоположение VARCHAR,
    статус book_status
) AS $$
BEGIN
	RETURN QUERY
    SELECT 
        b.name::VARCHAR,
        (a.surname || ' ' || a.name)::VARCHAR,
        bi.state,
        bi.location::VARCHAR,
        bi.status
    FROM book b
    JOIN author a ON b.author_id = a.id
    JOIN book_instance bi ON b.id = bi.book_id
    WHERE b.name = book_name
    ORDER BY 
        CASE bi.state
            WHEN 'отличное' THEN 1
            WHEN 'хорошее' THEN 2
            WHEN 'удовлетворительное' THEN 3
            WHEN 'ветхое' THEN 4
            WHEN 'утеряна' THEN 5
            ELSE 6
        END,
        bi.location;
END;
$$ LANGUAGE plpgsql;


	--15--

CREATE VIEW available_books_summary AS
SELECT 
    b.name AS книга,
    a.surname || ' ' || a.name AS автор,
    bi.state AS состояние,
    COUNT(bi.inventory_number) AS количество_экземпляров,
    STRING_AGG(bi.location_, ', ') AS местоположения
FROM book b
JOIN author a ON b.author_id = a.id
JOIN book_instance bi ON b.id = bi.information
WHERE bi.status = 'в наличии'  
AND NOT EXISTS (
    SELECT 1 FROM booking bk
    WHERE bk.book_id = b.id
    AND bk.booking_datetime >= CURRENT_TIMESTAMP - INTERVAL '3 days'
)
GROUP BY 
    b.id, 
    b.name, 
    a.surname, 
    a.name, 
    bi.state
ORDER BY 
    b.name,
    CASE bi.state
        WHEN 'отличное' THEN 1
        WHEN 'хорошее' THEN 2
        WHEN 'удовлетворительное' THEN 3
        WHEN 'ветхое' THEN 4
        ELSE 5
    END;