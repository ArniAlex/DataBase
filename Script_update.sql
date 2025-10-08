--CREATE DATABASE t01_library;

--CREATE TYPE book_state AS ENUM ('отличное', 'хорошее', 'удовлетворительное', 'ветхое', 'утеряна');
--CREATE TYPE book_status AS ENUM ('в наличии', 'выдана', 'забронирована');


CREATE TABLE IF NOT EXISTS public.author ( --2
	id SERIAL PRIMARY KEY,
	surname VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.publishing_house ( --3
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE,
	town VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.book ( --4
	id SERIAL PRIMARY KEY, 
	name VARCHAR(50) NOT NULL,
	author_id INTEGER NOT NULL, --FK на public.author
	publishing_house_id INTEGER NOT NULL, --FK на public.publishing_house
	version_publishing VARCHAR(50) NOT NULL,
	year_of_publishing INTEGER NOT NULL,
	circulation INTEGER NOT NULL CHECK (circulation > 0),
	
    CONSTRAINT fk_author 
        FOREIGN KEY (author_id) 
        REFERENCES public.author(id),

    CONSTRAINT fk_publishing_house  
        FOREIGN KEY (publishing_house_id)  
        REFERENCES public.publishing_house(id)
);

CREATE TABLE IF NOT EXISTS public.reader ( --5
	card_number SERIAL PRIMARY KEY,
	surname VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL,
	date_of_birth DATE NOT NULL CHECK (date_of_birth >= '1900-01-01' AND date_of_birth <= (NOW())::DATE),
	gender VARCHAR(1) NOT NULL CHECK (gender IN ('W', 'M')),
	registration_date DATE NOT NULL
); 



CREATE TABLE IF NOT EXISTS public.book_instance (--6
	inventory_number SERIAL PRIMARY KEY,
	information INTEGER NOT NULL, --FK на public.book
	state book_state NOT NULL,  
	status book_status NOT NULL, 
	location_ VARCHAR(100) NOT NULL CHECK (location_ ~ '^/\d+/\d+/\d+$'),--/ряд/шкаф/полка
	   
	CONSTRAINT fk_book 
        FOREIGN KEY (information)  
        REFERENCES public.book(id)
); 

CREATE TABLE IF NOT EXISTS public.issuance ( --7
	card_number INTEGER NOT NULL,
	inventory_number INTEGER NOT NULL,
	issue_date TIMESTAMP(0) NOT NULL, 
	expected_return_date DATE NOT NULL,
	actual_return_date DATE NULL,
	
	CONSTRAINT issuance_pk PRIMARY KEY (card_number, inventory_number),
	
	CONSTRAINT fk_issuance_reader 
        FOREIGN KEY (card_number)  
        REFERENCES public.reader(card_number),
    
    CONSTRAINT fk_issuance_book_instance 
        FOREIGN KEY (inventory_number)  
        REFERENCES public.book_instance(inventory_number),
        
    CONSTRAINT chk_issuance_dates 
        CHECK (actual_return_date IS NULL OR actual_return_date >= issue_date::DATE)
);

CREATE TABLE IF NOT EXISTS public.booking ( --8
	booking_number SERIAL PRIMARY KEY,
    card_number INTEGER NOT NULL, -- FK на public.reader
    book_id INTEGER NOT NULL, -- FK на public.book
    min_condition_level book_state NOT NULL, 
    booking_datetime TIMESTAMP(0) NOT NULL, -- точность до секунд
    
    CONSTRAINT fk_reader 
        FOREIGN KEY (card_number) 
        REFERENCES public.reader(card_number),
    
    CONSTRAINT fk_book 
        FOREIGN KEY (book_id) 
        REFERENCES public.book(id)
); 



