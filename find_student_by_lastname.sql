CREATE OR REPLACE FUNCTION find_student_by_lastname (p_last_name IN VARCHAR2)
RETURN NUMBER
IS
  v_student_id students.student_id%TYPE;
BEGIN
  SELECT student_id
    INTO v_student_id
    FROM students
   WHERE UPPER(last_name) = UPPER(p_last_name);

  RETURN v_student_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'No student found with last name ' || p_last_name || '.');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20004, 'More than one student has last name ' || p_last_name || '. Search by ID instead.');
END find_student_by_lastname;
/
SHOW ERRORS