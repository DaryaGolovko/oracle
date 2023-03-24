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
CREATE TABLE LogsTable ( 
    id NUMBER PRIMARY KEY NOT NULL, 
    date_time TIMESTAMP NOT NULL, 
    description VARCHAR2(100) NOT NULL,
    new_id NUMBER, 
    old_id NUMBER, 
    new_name VARCHAR2(20), 
    old_name VARCHAR2(20), 
    new_group_id NUMBER, 
    old_group_id NUMBER
);

CREATE OR REPLACE TRIGGER StudentsLogs
    AFTER INSERT OR UPDATE OR DELETE ON Students FOR EACH ROW 
DECLARE 
    id NUMBER;
BEGIN
    SELECT COUNT(*) INTO id FROM LogsTable;
    
    CASE
        WHEN INSERTING THEN
            INSERT INTO LogsTable VALUES (
                id + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING',
                :NEW.id, NULL, :NEW.name, NULL, :NEW.group_id, NULL);
        WHEN UPDATING THEN
            INSERT INTO LogsTable VALUES (
                id + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING',
                :NEW.id, :OLD.id, :NEW.name, :OLD.name, :NEW.group_id, :OLD.group_id);
        WHEN DELETING THEN
            INSERT INTO LogsTable VALUES (
                id + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING',
                NULL, :OLD.id, NULL, :OLD.name, NULL, :OLD.group_id);
    END CASE;
END;

--tests and helpers
ALTER TABLE Groups DISABLE ALL TRIGGERS;
ALTER TABLE Students DISABLE ALL TRIGGERS;
ALTER TRIGGER studentslogs ENABLE;
ALTER TRIGGER UpdateStudentsNumber ENABLE;

UPDATE Students SET group_id = 5 WHERE name = 'A';

SELECT * FROM Students;
SELECT * FROM Groups;
SELECT * FROM LogsTable;

--5th
CREATE OR REPLACE PROCEDURE RestoreData(time TIMESTAMP) IS
BEGIN
    FOR action IN (SELECT * FROM LogsTable WHERE time < date_time ORDER BY id DESC)
    LOOP
        CASE
            WHEN action.description = 'INSERTING' THEN
                DELETE FROM Students WHERE id = action.new_id;
            WHEN action.description = 'UPDATING' THEN
                UPDATE Students SET id = action.old_id,
                        name = action.old_name,
                        group_id = action.old_group_id
                    WHERE id = action.new_id;
            WHEN action.description = 'DELETING' THEN
                INSERT INTO Students VALUES (
                    action.old_id, action.old_name, action.old_group_id);
        END CASE;
    END LOOP;
END RestoreData;

-- interval??
CREATE OR REPLACE PROCEDURE RestoreDataInterval(time_interval INTERVAL DAY TO SECOND) IS
BEGIN
    RestoreData(TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')) - time_interval);
END RestoreDataInterval;

--helpers and tests
BEGIN
    RestoreData(TO_TIMESTAMP('24-MAR-23 12.39.55.000000000 AM'));
END;

BEGIN
    RestoreData(TO_TIMESTAMP(CURRENT_TIMESTAMP - 10));
END;

BEGIN
    RestoreDataInterval(INTERVAL '1' DAY);
END;


