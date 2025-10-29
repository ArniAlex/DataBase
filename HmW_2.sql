--1--
SELECT DISTINCT c.surname 
FROM client c 
JOIN subscription s ON c.subscription_id = s.id
WHERE s.name = 'demo_sub';


--2--
--Выбрать всех клиентов, подписка которых заканчивается в текущем году.
 SELECT c.surname, c.name 
 FROM client c 
WHERE EXTRACT(YEAR FROM c.subscription_end) = EXTRACT(YEAR FROM CURRENT_DATE);


--3--
SELECT s.name 
FROM subscription s 
JOIN client c ON c.subscription_id = s.id
GROUP BY s.name
HAVING COUNT(DISTINCT c.surname) > 10;


--4--
SELECT s.name 
FROM "subscription" s 
JOIN sub_to_service sts ON sts.sub_id = s.id 
GROUP BY s.name 
HAVING COUNT(DISTINCT sts.service_id) > 5;


--5--
SELECT c.name, c.surname
FROM client c
JOIN subscription s ON c.subscription_id = s.id
JOIN sub_to_service sts ON s.id = sts.sub_id
JOIN service serv ON sts.service_id = serv.id
WHERE c.sex = TRUE
    AND  serv.name = 'отчислиться на АиСД';


--6--
SELECT sr.name, s.name 
FROM service sr 
FULL JOIN sub_to_service sts ON sr.id = sts.service_id 
FULL JOIN subscription s ON sts.sub_id = s.id


--7--
SELECT c.surname, c.name 
FROM client c 
WHERE c.subscription_end < CURRENT_DATE;


--8--
SELECT c.name, c.surname
FROM client c
JOIN subscription s ON c.subscription_id = s.id
JOIN sub_to_service sts ON s.id = sts.sub_id
JOIN service sr ON sts.service_id = sr.id
WHERE sr.name = 'ПМИ' AND c.subscription_end = '2025-11-03'::DATE;


--9--
SELECT c.surname, c.name
FROM client c
JOIN subscription s ON s.id = c.subscription_id
WHERE s.price > 52000;


--10--
SELECT DISTINCT c.surname, c.name
FROM client c
JOIN subscription s ON s.id = c.subscription_id
JOIN sub_to_service sts ON s.id = sts.sub_id 
WHERE c.sex = FALSE AND sts.service_id = 3;


--11--
CREATE OR REPLACE VIEW active_services AS SELECT DISTINCT s.id, s.name
FROM service s 
JOIN sub_to_service sts ON s.id = sts.service_id 
JOIN subscription sub ON sts.sub_id = sub.id
JOIN client c ON sub.id = c.subscription_id;


--12--
CREATE OR REPLACE FUNCTION assign_subscription_by_id(
    client_id INT,
    subscription_id INT,
    duration_months INT DEFAULT 12
) RETURNS VOID AS $$
BEGIN
    UPDATE client 
    SET subscription_id = assign_subscription_by_id.subscription_id, 
        subscription_start = CURRENT_DATE,
        subscription_end = CURRENT_DATE + (duration_months || ' months')::INTERVAL
    WHERE id = client_id;
END;
$$ LANGUAGE plpgsql;


--13--
CREATE OR REPLACE FUNCTION assign_subscription_by_name(
    client_id INT,
    subscription_name VARCHAR,
    duration_months INT DEFAULT 12
) RETURNS VOID AS $$
DECLARE
    sub_id INT;
BEGIN
    SELECT id INTO sub_id FROM subscription WHERE name = subscription_name;
    UPDATE client 
    SET subscription_id = sub_id,
        subscription_start = CURRENT_DATE,
        subscription_end = CURRENT_DATE + (duration_months || ' months')::INTERVAL
    WHERE id = client_id;
END;
$$ LANGUAGE plpgsql;


--14--
SELECT COUNT(*)
FROM public.client c
JOIN public.subscription su ON c.subscription_id = su.id
JOIN public.sub_to_service sts ON su.id = sts.sub_id
JOIN public.service se ON sts.service_id = se.id
WHERE EXTRACT(YEAR FROM AGE(c.birthday)) > 35 AND su.name = 'Бонусы для 2 курса' AND c.sex = true;


--15--
SELECT s.id, s.name
FROM subscription s 
JOIN sub_to_service sts ON s.id = sts.sub_id
JOIN client c ON s.id = c.subscription_id
WHERE s.price > 85000::money
GROUP BY s.id, s.name
HAVING COUNT(DISTINCT sts.service_id) <= 10 AND COUNT(DISTINCT CASE WHEN c.sex = TRUE THEN c.id END) >= 10 AND COUNT(DISTINCT CASE WHEN c.sex = FALSE THEN c.id END) >= 10;