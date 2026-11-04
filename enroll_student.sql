CREATE OR REPLACE PROCEDURE enroll_student (
  p_student_id    IN  NUMBER,
  p_course_id     IN  NUMBER,
  p_semester      IN  VARCHAR2,
  p_enrollment_id OUT NUMBER
)
IS
  v_student      students%ROWTYPE;                 -- %ROWTYPE record
  v_course_title courses.course_title%TYPE;
  v_new_id       NUMBER;
  e_student_not_active EXCEPTION;                  -- user-defined exception
BEGIN
  BEGIN
    SELECT * INTO v_student FROM students WHERE student_id = p_student_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20020, 'Student ' || p_student_id || ' does not exist.');
  END;

  IF v_student.status <> 'ACTIVE' THEN
    RAISE e_student_not_active;
  END IF;

  BEGIN
    SELECT course_title INTO v_course_title FROM courses WHERE course_id = p_course_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20022, 'Course ' || p_course_id || ' does not exist.');
  END;

  v_new_id := seq_enrollment.NEXTVAL;

  INSERT INTO enrollments (enrollment_id, student_id, course_id, semester)
  VALUES (v_new_id, p_student_id, p_course_id, p_semester);

  p_enrollment_id := v_new_id;
  DBMS_OUTPUT.PUT_LINE(v_student.first_name || ' ' || v_student.last_name ||
                       ' enrolled in ' || v_course_title ||
                       ' | enrollment_id = ' || v_new_id ||
                       ' | rows inserted = ' || SQL%ROWCOUNT);
  COMMIT;
EXCEPTION
  WHEN e_student_not_active THEN
    RAISE_APPLICATION_ERROR(-20021, 'Student ' || p_student_id || ' is ' || v_student.status || ' and cannot enroll.');
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20023, 'Student ' || p_student_id || ' is already enrolled in course ' || p_course_id || ' for ' || p_semester || '.');
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('ENROLL_STUDENT', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END enroll_student;
/
SHOW ERRORS