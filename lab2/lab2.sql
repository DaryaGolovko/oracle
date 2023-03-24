--helpers general
DROP TABLE Students;
DROP TABLE Groups;

SELECT * FROM Students;
SELECT * FROM Groups;
SELECT * FROM Logs;

--helpers test triggers
ALTER TABLE Groups DISABLE ALL TRIGGERS;
ALTER TABLE Students DISABLE ALL TRIGGERS;

ALTER TRIGGER generate_groups_id ENABLE;
ALTER TRIGGER CheckIdGroups ENABLE;
ALTER TRIGGER CheckIdStudents ENABLE; 

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
--helpers
INSERT INTO Groups(name) VALUES('1');
INSERT INTO Groups(name) VALUES('2');
INSERT INTO Groups(name) VALUES('3');
INSERT INTO Groups(name) VALUES('4');
INSERT INTO Groups(name) VALUES('5');

INSERT INTO Students(name, group_id) VALUES('A', 1);
INSERT INTO Students(name, group_id) VALUES('B', 2);
INSERT INTO Students(name, group_id) VALUES('C', 3);

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

--tests
ALTER TRIGGER CheckIdGroups ENABLE;
INSERT INTO Groups(name) VALUES('1');
ALTER TABLE Groups DISABLE ALL TRIGGERS;

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

--tests
select * from students;

ALTER TRIGGER CheckIdGroups ENABLE;
ALTER TRIGGER CheckIdStudents ENABLE;

INSERT INTO Groups(id, name) VALUES(1, '10');
select * from GROUPS;

ALTER TRIGGER CheckIdGroups DISABLE;
ALTER TRIGGER CheckIdStudents DISABLE;

--autoincrement
--helpers sequence
CREATE SEQUENCE GroupsSequence
    START WITH 1 
    INCREMENT BY 1;

CREATE  SEQUENCE StudentsSequence
    START WITH 1 
    INCREMENT BY 1;

--drop sequence GROUPSSEQUENCE;


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

--tests
DELETE FROM Groups WHERE id = 2;
select * from GROUPS;
select * from STUDENTS;


--4th logs
--???
--5th logs restoring - later

