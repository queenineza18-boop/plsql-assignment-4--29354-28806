CREATE OR REPLACE FUNCTION get_student_name (p_student_id IN NUMBER)
RETURN VARCHAR2
IS
  v_name VARCHAR2(101);
BEGIN
  SELECT first_name || ' ' || last_name
    INTO v_name
    FROM students
   WHERE student_id = p_student_id;

  RETURN v_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'Student ' || p_student_id || ' does not exist.');
END get_student_name;
/
SHOW ERRORS