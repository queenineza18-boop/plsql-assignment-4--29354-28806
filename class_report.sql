CREATE OR REPLACE PROCEDURE class_report (
  p_course_id IN NUMBER,
  p_semester  IN VARCHAR2
)
IS
  CURSOR c_class IS
    SELECT s.student_id,
           s.first_name || ' ' || s.last_name AS full_name,
           e.marks,
           e.grade
      FROM enrollments e
      JOIN students s ON s.student_id = e.student_id
     WHERE e.course_id = p_course_id
       AND e.semester  = p_semester
     ORDER BY e.marks DESC NULLS LAST;

  TYPE t_row IS RECORD (                           -- user-defined record
    student_id students.student_id%TYPE,
    full_name  VARCHAR2(101),
    marks      enrollments.marks%TYPE,
    grade      enrollments.grade%TYPE
  );
  TYPE t_row_list    IS TABLE OF t_row;                            -- nested table
  TYPE t_grade_count IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(2); -- associative array

  v_rows   t_row_list := t_row_list();
  v_counts t_grade_count;
  v_key    VARCHAR2(2);
BEGIN
  FOR r IN c_class LOOP                            -- cursor FOR loop
    v_rows.EXTEND;
    v_rows(v_rows.LAST).student_id := r.student_id;
    v_rows(v_rows.LAST).full_name  := r.full_name;
    v_rows(v_rows.LAST).marks      := r.marks;
    v_rows(v_rows.LAST).grade      := r.grade;

    IF r.grade IS NOT NULL THEN
      IF v_counts.EXISTS(r.grade) THEN
        v_counts(r.grade) := v_counts(r.grade) + 1;
      ELSE
        v_counts(r.grade) := 1;
      END IF;
    END IF;
  END LOOP;

  IF v_rows.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20050, 'No enrollments found for course ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('=== CLASS REPORT: course ' || p_course_id || ', ' || p_semester || ' (' || v_rows.COUNT || ' students) ===');
  FOR i IN 1 .. v_rows.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(v_rows(i).student_id, 6) || RPAD(v_rows(i).full_name, 26) ||
                         'Marks: ' || RPAD(NVL(TO_CHAR(v_rows(i).marks), '-'), 7) ||
                         'Grade: ' || NVL(v_rows(i).grade, '-'));
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('--- Grade summary ---');
  v_key := v_counts.FIRST;
  WHILE v_key IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('Grade ' || v_key || ': ' || v_counts(v_key) || ' student(s)');
    v_key := v_counts.NEXT(v_key);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('CLASS_REPORT', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END class_report;
/
SHOW ERRORS