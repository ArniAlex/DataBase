


--1--
--реализовать сценарии добавления/удаления/редактирования авторов. Результатом запроса на добавление должны являться сгенерированные системой 
--значения атрибутов сущности, входящие в ограничение первичного ключа. Ключевым 
--параметром запросов на удаление/редактирование должны являться значения атрибутов 
--сущности, входящие в ограничение первичного ключа.
CREATE OR REPLACE PROCEDURE aut_manage (
    op INT,  -- operation type(1 - insert, 2 - update, 3 - delete)
    a_surname VARCHAR(50) DEFAULT NULL,
    a_name VARCHAR(50) DEFAULT NULL,
    INOUT a_id INT DEFAULT NULL
)
AS $$
BEGIN
    CASE op
        WHEN 1 THEN
            IF a_surname IS NULL OR a_name IS NULL THEN
                RAISE NOTICE 'Error: For ADD operation, surname and name are required';
                RETURN;
            END IF;

            IF EXISTS (SELECT 1 FROM author WHERE surname = a_surname AND name = a_name) THEN
                RAISE NOTICE 'Author already exists: % %', a_surname, a_name;
                SELECT id INTO a_id FROM author WHERE surname = a_surname AND name = a_name;
				RAISE NOTICE 'Existing author ID: %', a_id;
            ELSE
                INSERT INTO author (surname, name) VALUES (a_surname, a_name)
                RETURNING id INTO a_id;
                RAISE NOTICE 'Author added successfully. Generated ID: %', a_id;
            END IF;

        WHEN 2 THEN
            IF a_id IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, author ID is required';
                RETURN;
            END IF;
            
            IF a_surname IS NULL OR a_name IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, both surname and name are required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM author WHERE id = a_id) THEN
                RAISE NOTICE 'Error: Author with ID % not found', a_id;
                RETURN;
            END IF;
            
            -- Update author
            UPDATE author 
            SET surname = a_surname, name = a_name 
            WHERE id = a_id;
            
            RAISE NOTICE 'Author with ID % updated successfully', a_id;

        WHEN 3 THEN
            IF a_id IS NULL THEN
                RAISE NOTICE 'Error: For DELETE operation, author ID is required';
                RETURN;
            END IF;
            IF NOT EXISTS (SELECT 1 FROM author WHERE id = a_id) THEN
                RAISE NOTICE 'Error: Author with ID % not found', a_id;
                RETURN;
            ELSE
                -- Delete author
                DELETE FROM author WHERE id = a_id;
                RAISE NOTICE 'Author with ID % deleted successfully', a_id;
            END IF;
            
        ELSE
            RAISE NOTICE 'Error: Unknown operation type';
    END CASE;
END;
$$ LANGUAGE plpgsql;



--2--
CREATE OR REPLACE PROCEDURE publishing_house_manage (
    op INT,
    h_name VARCHAR(50) DEFAULT NULL,
    h_town VARCHAR(50) DEFAULT NULL,
    INOUT h_id INT DEFAULT NULL
)
AS $$
BEGIN
    CASE op 
        WHEN 1 THEN 
            IF h_name IS NULL OR h_town IS NULL THEN
                RAISE NOTICE 'Error: For ADD operation, name and town are required';
                RETURN;
            END IF; 

            IF EXISTS (SELECT 1 FROM publishing_house WHERE name = h_name AND town = h_town) THEN
                RAISE NOTICE 'Publishing house already exists: % in %', h_name, h_town;
                SELECT id INTO h_id FROM publishing_house WHERE name = h_name AND town = h_town;
                RAISE NOTICE 'Existing publishing house ID: %', h_id;
            ELSE 
                INSERT INTO publishing_house(name, town) VALUES(h_name, h_town)
                RETURNING id INTO h_id;
                RAISE NOTICE 'Publishing house added successfully. Generated ID: %', h_id;
            END IF;
            
        WHEN 2 THEN 
            IF h_id IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, publishing house ID is required';
                RETURN;
            END IF;
            
            IF h_name IS NULL OR h_town IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, both name and town are required';
                RETURN;
            END IF; 
            
            IF NOT EXISTS (SELECT 1 FROM publishing_house WHERE id = h_id) THEN 
                RAISE NOTICE 'Error: Publishing house with ID % not found', h_id;
                RETURN; 
            ELSE 
                UPDATE publishing_house 
                SET name = h_name, town = h_town
                WHERE id = h_id;
                
                RAISE NOTICE 'Publishing house with ID % updated successfully', h_id;
            END IF;
            
        WHEN 3 THEN 
            IF h_id IS NULL THEN 
                RAISE NOTICE 'Error: For DELETE operation, publishing house ID is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM publishing_house WHERE id = h_id) THEN 
                RAISE NOTICE 'Error: Publishing house with ID % not found', h_id;
                RETURN;
            ELSE 
                DELETE FROM publishing_house WHERE id = h_id;
                RAISE NOTICE 'Publishing house with ID % deleted successfully', h_id;
            END IF;
            
        ELSE
            RAISE NOTICE 'Error: Unknown operation type';
    END CASE;
END;
$$ LANGUAGE plpgsql;

--3--
CREATE OR REPLACE PROCEDURE book_manage (
    op INT,
    b_name VARCHAR(50) DEFAULT NULL,
    a_surname VARCHAR(50) DEFAULT NULL,
    a_name VARCHAR(50) DEFAULT NULL,
    ph_name VARCHAR(50) DEFAULT NULL,
    ph_town VARCHAR(50) DEFAULT NULL,
    b_version_publishing VARCHAR(50) DEFAULT NULL,
    b_year_of_publishing INT DEFAULT NULL,
    b_circulation INT DEFAULT NULL,
    INOUT b_id INT DEFAULT NULL,
    INOUT a_id INT DEFAULT NULL,
    INOUT ph_id INT DEFAULT NULL
)
AS $$
BEGIN
    CASE op
        WHEN 1 THEN 
            IF b_name IS NULL OR b_version_publishing IS NULL OR 
               b_year_of_publishing IS NULL OR b_circulation IS NULL THEN
                RAISE NOTICE 'Error: For ADD operation, book name, version, year and circulation are required';
                RETURN;
            END IF;
            
            
            IF a_id IS NULL AND (a_surname IS NULL OR a_name IS NULL) THEN
                RAISE NOTICE 'Error: For ADD operation, either author ID or author surname and name are required';
                RETURN;
            END IF;
            
            
            IF ph_id IS NULL AND (ph_name IS NULL OR ph_town IS NULL) THEN
                RAISE NOTICE 'Error: For ADD operation, either publishing house ID or publishing house name and town are required';
                RETURN;
            END IF;
            
            
            IF a_id IS NOT NULL THEN
                IF NOT EXISTS (SELECT 1 FROM author WHERE id = a_id) THEN
                    RAISE NOTICE 'Error: Author with ID % not found', a_id;
                    RETURN;
                END IF;
            ELSE
                
                SELECT id INTO a_id FROM author 
                WHERE surname = a_surname AND name = a_name;
                
                IF a_id IS NULL THEN
                    
                    INSERT INTO author (surname, name) 
                    VALUES (a_surname, a_name)
                    RETURNING id INTO a_id;
                    RAISE NOTICE 'New author created with ID: %', a_id;
                END IF;
            END IF;
            
            IF ph_id IS NOT NULL THEN
                IF NOT EXISTS (SELECT 1 FROM publishing_house WHERE id = ph_id) THEN
                    RAISE NOTICE 'Error: Publishing house with ID % not found', ph_id;
                    RETURN;
                END IF;
            ELSE
                
                SELECT id INTO ph_id FROM publishing_house 
                WHERE name = ph_name AND town = ph_town;
                
                IF ph_id IS NULL THEN
                    
                    INSERT INTO publishing_house (name, town)
                    VALUES (ph_name, ph_town)
                    RETURNING id INTO ph_id;
                    RAISE NOTICE 'New publishing house created with ID: %', ph_id;
                END IF;
            END IF;
            
            
            IF EXISTS (SELECT 1 FROM book 
                      WHERE name = b_name AND author_id = a_id 
                      AND publishing_house_id = ph_id AND version_publishing = b_version_publishing) THEN
                RAISE NOTICE 'Book already exists: "%" by author ID % from publishing house ID %', 
                    b_name, a_id, ph_id;
                SELECT id INTO b_id FROM book 
                WHERE name = b_name AND author_id = a_id 
                AND publishing_house_id = ph_id AND version_publishing = b_version_publishing;
                RAISE NOTICE 'Existing book ID: %', b_id;
            ELSE
                
                INSERT INTO book (name, author_id, publishing_house_id, version_publishing, year_of_publishing, circulation)
                VALUES (b_name, a_id, ph_id, b_version_publishing, b_year_of_publishing, b_circulation)
                RETURNING id INTO b_id;
                RAISE NOTICE 'Book added successfully. Generated ID: %', b_id;
            END IF;

        WHEN 2 THEN 
            IF b_id IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, book ID is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM book WHERE id = b_id) THEN
                RAISE NOTICE 'Error: Book with ID % not found', b_id;
                RETURN;
            END IF;
            
            
            UPDATE book 
            SET name = CASE WHEN b_name IS NOT NULL THEN b_name ELSE name END,
                version_publishing = CASE WHEN b_version_publishing IS NOT NULL THEN b_version_publishing ELSE version_publishing END,
                year_of_publishing = CASE WHEN b_year_of_publishing IS NOT NULL THEN b_year_of_publishing ELSE year_of_publishing END,
                circulation = CASE WHEN b_circulation IS NOT NULL THEN b_circulation ELSE circulation END
            WHERE id = b_id;
            
            RAISE NOTICE 'Book with ID % updated successfully', b_id;

        WHEN 3 THEN 
            IF b_id IS NULL THEN
                RAISE NOTICE 'Error: For DELETE operation, book ID is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM book WHERE id = b_id) THEN
                RAISE NOTICE 'Error: Book with ID % not found', b_id;
                RETURN;
            ELSE
                DELETE FROM book WHERE id = b_id;
                RAISE NOTICE 'Book with ID % deleted successfully', b_id;
            END IF;
            
        ELSE
            RAISE NOTICE 'Error: Unknown operation type';
    END CASE;
END;
$$ LANGUAGE plpgsql;

--4--
CREATE OR REPLACE PROCEDURE reader_manage (
    op INT,
    r_surname VARCHAR(50) DEFAULT NULL,
    r_name VARCHAR(50) DEFAULT NULL,
    r_date_of_birth DATE DEFAULT NULL,
    r_gender VARCHAR(1) DEFAULT NULL,
    r_registration_date DATE DEFAULT NULL,
    INOUT r_card_number INT DEFAULT NULL
)
AS $$
BEGIN
    CASE op
        WHEN 1 THEN
            IF r_surname IS NULL OR r_name IS NULL OR r_date_of_birth IS NULL OR 
               r_gender IS NULL OR r_registration_date IS NULL THEN
                RAISE NOTICE 'Error: For ADD operation, all parameters are required';
                RETURN;
            END IF;
            
            IF EXISTS (SELECT 1 FROM reader 
                      WHERE surname = r_surname AND name = r_name AND date_of_birth = r_date_of_birth) THEN
                RAISE NOTICE 'Reader already exists: % %', r_surname, r_name;
                SELECT card_number INTO r_card_number FROM reader 
                WHERE surname = r_surname AND name = r_name AND date_of_birth = r_date_of_birth;
                RAISE NOTICE 'Existing reader card number: %', r_card_number;
            ELSE
                INSERT INTO reader (surname, name, date_of_birth, gender, registration_date)
                VALUES (r_surname, r_name, r_date_of_birth, r_gender, r_registration_date)
                RETURNING card_number INTO r_card_number;
                RAISE NOTICE 'Reader added successfully. Generated card number: %', r_card_number;
            END IF;

        WHEN 2 THEN
            IF r_card_number IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, card number is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM reader WHERE card_number = r_card_number) THEN
                RAISE NOTICE 'Error: Reader with card number % not found', r_card_number;
                RETURN;
            END IF;
            
            UPDATE reader 
            SET surname = CASE WHEN r_surname IS NOT NULL THEN r_surname ELSE surname END,
                name = CASE WHEN r_name IS NOT NULL THEN r_name ELSE name END,
                date_of_birth = CASE WHEN r_date_of_birth IS NOT NULL THEN r_date_of_birth ELSE date_of_birth END,
                gender = CASE WHEN r_gender IS NOT NULL THEN r_gender ELSE gender END,
                registration_date = CASE WHEN r_registration_date IS NOT NULL THEN r_registration_date ELSE registration_date END
            WHERE card_number = r_card_number;
            
            RAISE NOTICE 'Reader with card number % updated successfully', r_card_number;

        WHEN 3 THEN
            IF r_card_number IS NULL THEN
                RAISE NOTICE 'Error: For DELETE operation, card number is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM reader WHERE card_number = r_card_number) THEN
                RAISE NOTICE 'Error: Reader with card number % not found', r_card_number;
                RETURN;
            ELSE
                DELETE FROM reader WHERE card_number = r_card_number;
                RAISE NOTICE 'Reader with card number % deleted successfully', r_card_number;
            END IF;
            
        ELSE
            RAISE NOTICE 'Error: Unknown operation type';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- 5--
CREATE OR REPLACE PROCEDURE book_instance_manage (
    op INT,
    bi_book_id INT DEFAULT NULL,
    bi_state book_state DEFAULT NULL,
    bi_status book_status DEFAULT NULL,
    bi_location VARCHAR(100) DEFAULT NULL,
    INOUT bi_inventory_number INT DEFAULT NULL
)
AS $$
BEGIN
    CASE op
        WHEN 1 THEN
            IF bi_book_id IS NULL OR bi_state IS NULL OR bi_status IS NULL OR bi_location IS NULL THEN
                RAISE NOTICE 'Error: For ADD operation, all parameters are required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM book WHERE id = bi_book_id) THEN
                RAISE NOTICE 'Error: Book with ID % not found', bi_book_id;
                RETURN;
            END IF;
            
            IF bi_location !~ '^/\d+/\d+/\d+$' THEN
                RAISE NOTICE 'Error: Location must be in format /row/cabinet/shelf';
                RETURN;
            END IF;
            
            INSERT INTO book_instance (information, state, status, location_)
            VALUES (bi_book_id, bi_state, bi_status, bi_location)
            RETURNING inventory_number INTO bi_inventory_number;
            
            RAISE NOTICE 'Book instance added successfully. Generated inventory number: %', bi_inventory_number;

        WHEN 2 THEN
            IF bi_inventory_number IS NULL THEN
                RAISE NOTICE 'Error: For EDIT operation, inventory number is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM book_instance WHERE inventory_number = bi_inventory_number) THEN
                RAISE NOTICE 'Error: Book instance with inventory number % not found', bi_inventory_number;
                RETURN;
            END IF;
            
            IF bi_location IS NOT NULL AND bi_location !~ '^/\d+/\d+/\d+$' THEN
                RAISE NOTICE 'Error: Location must be in format /row/cabinet/shelf';
                RETURN;
            END IF;
            
            UPDATE book_instance 
            SET information = CASE WHEN bi_book_id IS NOT NULL THEN bi_book_id ELSE information END,
                state = CASE WHEN bi_state IS NOT NULL THEN bi_state ELSE state END,
                status = CASE WHEN bi_status IS NOT NULL THEN bi_status ELSE status END,
                location_ = CASE WHEN bi_location IS NOT NULL THEN bi_location ELSE location_ END
            WHERE inventory_number = bi_inventory_number;
            
            RAISE NOTICE 'Book instance with inventory number % updated successfully', bi_inventory_number;

        WHEN 3 THEN
            IF bi_inventory_number IS NULL THEN
                RAISE NOTICE 'Error: For DELETE operation, inventory number is required';
                RETURN;
            END IF;
            
            IF NOT EXISTS (SELECT 1 FROM book_instance WHERE inventory_number = bi_inventory_number) THEN
                RAISE NOTICE 'Error: Book instance with inventory number % not found', bi_inventory_number;
                RETURN;
            ELSE
                DELETE FROM book_instance WHERE inventory_number = bi_inventory_number;
                RAISE NOTICE 'Book instance with inventory number % deleted successfully', bi_inventory_number;
            END IF;
            
        ELSE
            RAISE NOTICE 'Error: Unknown operation type';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- 6
DROP PROCEDURE IF EXISTS issue_book(integer,integer,date);

CREATE OR REPLACE PROCEDURE issue_book (
    reader_card INT,
    book_copy_id INT,
    return_date DATE
)
AS $$
DECLARE
    book_status_var book_status;
BEGIN
    SELECT status INTO book_status_var FROM book_instance WHERE inventory_number = book_copy_id;
    
    IF NOT EXISTS (SELECT 1 FROM reader WHERE card_number = reader_card) THEN
        RAISE NOTICE 'Нет читателя';
        RETURN;
    END IF;
    
    IF book_status_var IS NULL THEN
        RAISE NOTICE 'Нет книги';
        RETURN;
    END IF;
    
    IF book_status_var != 'в наличии' THEN
        RAISE NOTICE 'Книга занята';
        RETURN;
    END IF;
    
    INSERT INTO issuance (card_number, inventory_number, issue_date, expected_return_date, actual_return_date)
    VALUES (reader_card, book_copy_id, CURRENT_TIMESTAMP, return_date, NULL);
    
    UPDATE book_instance SET status = 'выдана' WHERE inventory_number = book_copy_id;
    
    RAISE NOTICE 'Книга выдана';
END;
$$ LANGUAGE plpgsql;

-- 7
DROP PROCEDURE IF EXISTS return_book(integer,integer);

CREATE OR REPLACE PROCEDURE return_book (
    reader_card INT,
    book_copy_id INT
)
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM issuance 
        WHERE card_number = reader_card 
        AND inventory_number = book_copy_id 
        AND actual_return_date IS NULL
    ) THEN
        RAISE NOTICE 'Нет выдачи';
        RETURN;
    END IF;
    
    UPDATE issuance SET actual_return_date = CURRENT_DATE
    WHERE card_number = reader_card 
    AND inventory_number = book_copy_id 
    AND actual_return_date IS NULL;
    
    UPDATE book_instance SET status = 'в наличии' WHERE inventory_number = book_copy_id;
    
    RAISE NOTICE 'Книга возвращена';
END;
$$ LANGUAGE plpgsql;

-- 8
DROP VIEW IF EXISTS issued_books_view;

CREATE OR REPLACE VIEW issued_books_view AS
SELECT 
    r.surname || ' ' || r.name AS reader_full_name,
    a.surname || ' ' || a.name AS author_full_name,
    b.name AS book_title,
    bi.state AS book_state,
    i.issue_date
FROM issuance i
JOIN reader r ON i.card_number = r.card_number
JOIN book_instance bi ON i.inventory_number = bi.inventory_number
JOIN book b ON bi.information = b.id
JOIN author a ON b.author_id = a.id
WHERE i.actual_return_date IS NULL;

-- 9
DROP VIEW IF EXISTS overdue_books_view;

CREATE OR REPLACE VIEW overdue_books_view AS
SELECT 
    r.surname || ' ' || r.name AS reader_full_name,
    a.surname || ' ' || a.name AS author_full_name,
    b.name AS book_title,
    CURRENT_DATE - i.expected_return_date AS days_overdue
FROM issuance i
JOIN reader r ON i.card_number = r.card_number
JOIN book_instance bi ON i.inventory_number = bi.inventory_number
JOIN book b ON bi.information = b.id
JOIN author a ON b.author_id = a.id
WHERE i.actual_return_date IS NULL 
AND i.expected_return_date < CURRENT_DATE;

-- 10
DROP PROCEDURE IF EXISTS issue_book_check_overdue(integer,integer,date);

CREATE OR REPLACE PROCEDURE issue_book_check_overdue (
    reader_card INT,
    book_copy_id INT,
    return_date DATE
)
AS $$
DECLARE
    book_status_var book_status;
    overdue_count INT;
BEGIN
    SELECT status INTO book_status_var FROM book_instance WHERE inventory_number = book_copy_id;
    
    SELECT COUNT(*) INTO overdue_count FROM overdue_books_view 
    WHERE reader_full_name = (SELECT surname || ' ' || name FROM reader WHERE card_number = reader_card);
    
    IF NOT EXISTS (SELECT 1 FROM reader WHERE card_number = reader_card) THEN
        RAISE NOTICE 'Нет читателя';
        RETURN;
    END IF;
    
    IF book_status_var IS NULL THEN
        RAISE NOTICE 'Нет книги';
        RETURN;
    END IF;
    
    IF book_status_var != 'в наличии' THEN
        RAISE NOTICE 'Книга занята';
        RETURN;
    END IF;
    
    IF overdue_count > 0 THEN
        RAISE NOTICE 'У читателя есть просрочки';
        RETURN;
    END IF;
    
    INSERT INTO issuance (card_number, inventory_number, issue_date, expected_return_date, actual_return_date)
    VALUES (reader_card, book_copy_id, CURRENT_TIMESTAMP, return_date, NULL);
    
    UPDATE book_instance SET status = 'выдана' WHERE inventory_number = book_copy_id;
    
    RAISE NOTICE 'Книга выдана';
END;
$$ LANGUAGE plpgsql;

-- 11
DROP PROCEDURE IF EXISTS reserve_book(integer,integer,book_state);

CREATE OR REPLACE PROCEDURE reserve_book (
    reader_card INT,
    book_id_var INT,
    min_condition_var book_state
)
AS $$
DECLARE
    available_copy_id INT;
    reader_exists BOOLEAN;
    book_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM reader WHERE card_number = reader_card) INTO reader_exists;
    SELECT EXISTS(SELECT 1 FROM book WHERE id = book_id_var) INTO book_exists;
    
    IF NOT reader_exists THEN
        RAISE NOTICE 'Нет читателя';
        RETURN;
    END IF;
    
    IF NOT book_exists THEN
        RAISE NOTICE 'Нет книги';
        RETURN;
    END IF;
    
    SELECT inventory_number INTO available_copy_id
    FROM book_instance 
    WHERE information = book_id_var 
    AND status = 'в наличии'
    ORDER BY 
        CASE state
            WHEN 'отличное' THEN 1
            WHEN 'хорошее' THEN 2
            WHEN 'удовлетворительное' THEN 3
            WHEN 'ветхое' THEN 4
            ELSE 5
        END
    LIMIT 1;
    
    IF available_copy_id IS NULL THEN
        RAISE NOTICE 'Нет доступных экземпляров';
        RETURN;
    END IF;
    
    INSERT INTO booking (card_number, book_id, min_condition_level, booking_datetime)
    VALUES (reader_card, book_id_var, min_condition_var, CURRENT_TIMESTAMP);
    
    UPDATE book_instance SET status = 'забронирована' WHERE inventory_number = available_copy_id;
    
    RAISE NOTICE 'Книга забронирована';
END;
$$ LANGUAGE plpgsql;

-- 12
DROP PROCEDURE IF EXISTS cancel_reservation(integer);

CREATE OR REPLACE PROCEDURE cancel_reservation (
    reservation_number INT
)
AS $$
DECLARE
    found_copy_id INT;
BEGIN
    SELECT bi.inventory_number INTO found_copy_id
    FROM booking b
    JOIN book_instance bi ON bi.information = b.book_id
    WHERE b.booking_number = reservation_number
    LIMIT 1;
    
    IF found_copy_id IS NULL THEN
        RAISE NOTICE 'Бронь не найдена';
        RETURN;
    END IF;
    
    DELETE FROM booking WHERE booking_number = reservation_number;
    
    UPDATE book_instance SET status = 'в наличии' WHERE inventory_number = found_copy_id;
    
    RAISE NOTICE 'Бронь отменена';
END;
$$ LANGUAGE plpgsql;

-- 13
DROP PROCEDURE IF EXISTS issue_book_check_reserved(integer,integer,date);

CREATE OR REPLACE PROCEDURE issue_book_check_reserved (
    reader_card INT,
    book_copy_id INT,
    return_date DATE
)
AS $$
DECLARE
    book_status_var book_status;
    overdue_count INT;
    is_reserved_var BOOLEAN;
BEGIN
    SELECT status INTO book_status_var FROM book_instance WHERE inventory_number = book_copy_id;
    
    SELECT COUNT(*) INTO overdue_count FROM overdue_books_view 
    WHERE reader_full_name = (SELECT surname || ' ' || name FROM reader WHERE card_number = reader_card);
    
    SELECT EXISTS (
        SELECT 1 FROM booking b
        JOIN book_instance bi ON bi.information = b.book_id
        WHERE bi.inventory_number = book_copy_id
        AND b.booking_datetime > CURRENT_TIMESTAMP - INTERVAL '3 days'
    ) INTO is_reserved_var;
    
    IF NOT EXISTS (SELECT 1 FROM reader WHERE card_number = reader_card) THEN
        RAISE NOTICE 'Нет читателя';
        RETURN;
    END IF;
    
    IF book_status_var IS NULL THEN
        RAISE NOTICE 'Нет книги';
        RETURN;
    END IF;
    
    IF book_status_var != 'в наличии' THEN
        RAISE NOTICE 'Книга занята';
        RETURN;
    END IF;
    
    IF overdue_count > 0 THEN
        RAISE NOTICE 'У читателя есть просрочки';
        RETURN;
    END IF;
    
    IF is_reserved_var THEN
        RAISE NOTICE 'Книга забронирована другим';
        RETURN;
    END IF;
    
    INSERT INTO issuance (card_number, inventory_number, issue_date, expected_return_date, actual_return_date)
    VALUES (reader_card, book_copy_id, CURRENT_TIMESTAMP, return_date, NULL);
    
    UPDATE book_instance SET status = 'выдана' WHERE inventory_number = book_copy_id;
    
    RAISE NOTICE 'Книга выдана';
END;
$$ LANGUAGE plpgsql;

-- 14
DROP FUNCTION IF EXISTS find_book_locations(integer);

CREATE OR REPLACE FUNCTION find_book_locations(book_id_param INT)
RETURNS TABLE(
    copy_id INT,
    copy_state book_state,
    copy_location VARCHAR(100),
    copy_status book_status
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bi.inventory_number,
        bi.state,
        bi.location_,
        bi.status
    FROM book_instance bi
    WHERE bi.information = book_id_param
    ORDER BY 
        CASE bi.state
            WHEN 'отличное' THEN 1
            WHEN 'хорошее' THEN 2
            WHEN 'удовлетворительное' THEN 3
            WHEN 'ветхое' THEN 4
            WHEN 'утеряна' THEN 5
            ELSE 6
        END;
END;
$$ LANGUAGE plpgsql;

-- 15
DROP VIEW IF EXISTS available_books_view;

CREATE OR REPLACE VIEW available_books_view AS
SELECT 
    b.id,
    b.name AS book_name,
    a.surname || ' ' || a.name AS author_name,
    bi.state,
    COUNT(*) AS copies_count
FROM book_instance bi
JOIN book b ON bi.information = b.id
JOIN author a ON b.author_id = a.id
WHERE bi.status = 'в наличии'
AND bi.inventory_number NOT IN (
    SELECT inventory_number FROM issuance WHERE actual_return_date IS NULL
)
GROUP BY b.id, b.name, a.surname, a.name, bi.state
ORDER BY b.name;

-- 16
DROP VIEW IF EXISTS long_overdue_books_view;

CREATE OR REPLACE VIEW long_overdue_books_view AS
SELECT 
    r.surname || ' ' || r.name AS reader_name,
    a.surname || ' ' || a.name AS author_name,
    b.name AS book_name,
    i.issue_date,
    i.expected_return_date,
    CURRENT_DATE - i.issue_date::DATE AS days_with_book
FROM issuance i
JOIN reader r ON i.card_number = r.card_number
JOIN book_instance bi ON i.inventory_number = bi.inventory_number
JOIN book b ON bi.information = b.id
JOIN author a ON b.author_id = a.id
WHERE i.actual_return_date IS NULL 
AND i.issue_date < CURRENT_DATE - INTERVAL '1 year';

-- 17
CREATE TABLE IF NOT EXISTS public.logs (
    log_id SERIAL PRIMARY KEY,
    log_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    table_name VARCHAR(50) NOT NULL,
    log_content TEXT NOT NULL
);

-- 18
-- 18
DROP TRIGGER IF EXISTS log_author ON author;
DROP TRIGGER IF EXISTS log_publishing_house ON publishing_house;
DROP TRIGGER IF EXISTS log_book ON book;
DROP TRIGGER IF EXISTS log_reader ON reader;
DROP TRIGGER IF EXISTS log_book_instance ON book_instance;
DROP TRIGGER IF EXISTS log_issuance ON issuance;
DROP TRIGGER IF EXISTS log_booking ON booking;

DROP FUNCTION IF EXISTS log_changes() CASCADE;

CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO logs (table_name, log_content)
        VALUES (TG_TABLE_NAME, 'Добавлена запись: ' || row_to_json(NEW)::TEXT);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO logs (table_name, log_content)
        VALUES (TG_TABLE_NAME, 'Обновлена запись. Было: ' || row_to_json(OLD)::TEXT || ' Стало: ' || row_to_json(NEW)::TEXT);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO logs (table_name, log_content)
        VALUES (TG_TABLE_NAME, 'Удалена запись: ' || row_to_json(OLD)::TEXT);
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_author
AFTER INSERT OR UPDATE OR DELETE ON author
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER log_publishing_house
AFTER INSERT OR UPDATE OR DELETE ON publishing_house
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER log_book
AFTER INSERT OR UPDATE OR DELETE ON book
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER log_reader
AFTER INSERT OR UPDATE OR DELETE ON reader
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER log_book_instance
AFTER INSERT OR UPDATE OR DELETE ON book_instance
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER log_issuance
AFTER INSERT OR UPDATE OR DELETE ON issuance
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER log_booking
AFTER INSERT OR UPDATE OR DELETE ON booking
FOR EACH ROW
EXECUTE FUNCTION log_changes();
