CREATE OR REPLACE PROCEDURE print_transcript (p_student_id IN NUMBER)
IS
  CURSOR c_transcript (cp_student_id NUMBER) IS
    SELECT c.course_code, c.course_title, c.credits, e.semester, e.marks, e.grade
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.student_id = cp_student_id
     ORDER BY e.semester, c.course_code;

  TYPE t_line IS RECORD (                          -- user-defined record
    course_code  courses.course_code%TYPE,
    course_title courses.course_title%TYPE,
    credits      courses.credits%TYPE,
    semester     enrollments.semester%TYPE,
    marks        enrollments.marks%TYPE,
    grade        enrollments.grade%TYPE
  );
  v_line  t_line;
  v_name  VARCHAR2(101);
  v_count PLS_INTEGER := 0;

  e_no_grades EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_no_grades, -20005);
BEGIN
  v_name := get_student_name(p_student_id);

  DBMS_OUTPUT.PUT_LINE('=== TRANSCRIPT: ' || v_name || ' (ID ' || p_student_id || ') ===');

  OPEN c_transcript(p_student_id);
  LOOP
    FETCH c_transcript INTO v_line;
    EXIT WHEN c_transcript%NOTFOUND;
    v_count := v_count + 1;
    DBMS_OUTPUT.PUT_LINE(RPAD(v_line.course_code, 10) || RPAD(v_line.course_title, 36) ||
                         RPAD(v_line.semester, 9) ||
                         'Marks: ' || RPAD(NVL(TO_CHAR(v_line.marks), '-'), 6) ||
                         'Grade: ' || NVL(v_line.grade, '-'));
  END LOOP;
  CLOSE c_transcript;

  IF v_count = 0 THEN
    DBMS_OUTPUT.PUT_LINE('No enrollments found for this student.');
  ELSE
    BEGIN
      DBMS_OUTPUT.PUT_LINE('GPA: ' || TO_CHAR(calculate_gpa(p_student_id), '0.00'));
    EXCEPTION
      WHEN e_no_grades THEN
        DBMS_OUTPUT.PUT_LINE('GPA: not available yet (no graded courses).');
    END;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_transcript%ISOPEN THEN
      CLOSE c_transcript;
    END IF;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('PRINT_TRANSCRIPT', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END print_transcript;
/
SHOW ERRORS