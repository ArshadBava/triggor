CREATE DATABASE IF NOT EXISTS student_db;
USE student_db;

CREATE TABLE IF NOT EXISTS students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gpa DECIMAL(3, 2)
);

CREATE TABLE IF NOT EXISTS audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    operation VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_gpa DECIMAL(3, 2),
    new_gpa DECIMAL(3, 2)
);

DELIMITER $$

CREATE TRIGGER validate_gpa
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    IF NEW.gpa < 0.0 OR NEW.gpa > 4.0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'GPA must be between 0.0 and 4.0';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER validate_gpa_update
BEFORE UPDATE ON students
FOR EACH ROW
BEGIN
    IF NEW.gpa < 0.0 OR NEW.gpa > 4.0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'GPA must be between 0.0 and 4.0';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER log_student_changes
AFTER UPDATE ON students
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (student_id, operation, old_gpa, new_gpa)
    VALUES (NEW.student_id, 'UPDATE', OLD.gpa, NEW.gpa);
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER log_student_insertions
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (student_id, operation, old_gpa, new_gpa)
    VALUES (NEW.student_id, 'INSERT', NULL, NEW.gpa);
END $$

DELIMITER ;

INSERT INTO students (name, age, gpa) VALUES ('John Doe', 20, 3.5);

UPDATE students SET gpa = 3.8 WHERE student_id = 1;

SELECT * FROM audit_log;
