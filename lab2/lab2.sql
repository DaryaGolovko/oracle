--1st task

CREATE TABLE Students (
    id NUMBER,
    name VARCHAR2(20),
    group_id NUMBER
);
  
CREATE TABLE Groups (
    id NUMBER,
    name VARCHAR2(20),
    c_val NUMBER
);

--2nd
--check unique group.name
CREATE OR REPLACE TRIGGER CheckUniqueGroupName
    BEFORE INSERT OR UPDATE OF NAME ON Groups 
    FOR EACH ROW 
DECLARE 
    num NUMBER;
BEGIN
    SELECT COUNT(*) 
    INTO num 
    FROM Groups 
    WHERE name = :NEW.name;
                
    IF num > 0 THEN    
        RAISE VALUE_ERROR; 
    END IF;
END;

--check unique id
CREATE OR REPLACE TRIGGER CheckIdStudents
    BEFORE INSERT ON Students
    FOR EACH ROW
DECLARE
    num NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO num
    FROM Students
    WHERE id = :NEW.id;
  
    IF num > 0 THEN
        RAISE VALUE_ERROR;
    END IF;
END;

CREATE OR REPLACE TRIGGER CheckIdGroups
    BEFORE INSERT ON Groups
    FOR EACH ROW
DECLARE
    num NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO num
    FROM Groups
    WHERE id = :NEW.id;
  
    IF num > 0 THEN
        RAISE VALUE_ERROR;
    END IF;
END;

--autoincrement
--helpers
CREATE SEQUENCE GroupsSequence
    START WITH 1 
    INCREMENT BY 1;

CREATE SEQUENCE StudentsSequence
    START WITH 1 
    INCREMENT BY 1;

--task
CREATE OR REPLACE TRIGGER IncrIdStudents
    BEFORE INSERT ON Students
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := StudentsSequence.NEXTVAL;
    END IF;
END;

CREATE OR REPLACE TRIGGER IncrIdGroups
    BEFORE INSERT ON Groups
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        :NEW.id := GroupsSequence.NEXTVAL;
    END IF;
END;

--3rd task delete cascade 
CREATE OR REPLACE TRIGGER ForeighnKeyDelete
    BEFORE DELETE ON Groups FOR EACH ROW 
BEGIN
    DELETE FROM Students WHERE group_id = :OLD.id;
END;

--4th logs


