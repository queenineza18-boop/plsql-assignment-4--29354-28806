CREATE OR REPLACE PROCEDURE register_student (
  p_first_name IN  VARCHAR2,
  p_last_name  IN  VARCHAR2,
  p_email      IN  VARCHAR2,
  p_dept_id    IN  NUMBER,
  p_student_id OUT NUMBER
)
IS
  e_invalid_input EXCEPTION;                       -- user-defined exception
  e_bad_dept      EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bad_dept, -2291);        -- parent key not found
  v_new_id NUMBER;
BEGIN
  IF p_first_name IS NULL OR p_last_name IS NULL
     OR p_email IS NULL OR INSTR(p_email, '@') = 0 THEN
    RAISE e_invalid_input;
  END IF;

  v_new_id := seq_student.NEXTVAL;

  INSERT INTO students (student_id, first_name, last_name, email, dept_id)
  VALUES (v_new_id, p_first_name, p_last_name, p_email, p_dept_id);

  IF SQL%ROWCOUNT = 1 THEN
    p_student_id := v_new_id;
    DBMS_OUTPUT.PUT_LINE('Student registered. ID = ' || v_new_id ||
                         ' | rows inserted = ' || SQL%ROWCOUNT);
  END IF;

  COMMIT;
EXCEPTION
  WHEN e_invalid_input THEN
    RAISE_APPLICATION_ERROR(-20010, 'First name, last name and a valid email (with @) are required.');
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20011, 'Email ' || p_email || ' is already registered.');
  WHEN e_bad_dept THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20012, 'Department ' || p_dept_id || ' does not exist.');
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('REGISTER_STUDENT', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END register_student;
/
SHOW ERRORS