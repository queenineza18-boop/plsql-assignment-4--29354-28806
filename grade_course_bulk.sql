CREATE OR REPLACE PROCEDURE grade_course_bulk (
  p_course_id IN  NUMBER,
  p_semester  IN  VARCHAR2,
  p_updated   OUT NUMBER
)
IS
  TYPE t_id_tab    IS TABLE OF enrollments.enrollment_id%TYPE;   -- nested tables
  TYPE t_marks_tab IS TABLE OF enrollments.marks%TYPE;
  TYPE t_grade_tab IS TABLE OF enrollments.grade%TYPE;

  v_ids    t_id_tab;
  v_marks  t_marks_tab;
  v_grades t_grade_tab := t_grade_tab();
  v_failed PLS_INTEGER := 0;

  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);    -- FORALL ... SAVE EXCEPTIONS error
BEGIN
  -- 1) ONE query brings all rows into memory
  SELECT enrollment_id, marks
    BULK COLLECT INTO v_ids, v_marks
    FROM enrollments
   WHERE course_id = p_course_id
     AND semester  = p_semester
     AND marks IS NOT NULL;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20060, 'No marked enrollments found for course ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  -- 2) Work out each grade in memory
  v_grades.EXTEND(v_ids.COUNT);
  FOR i IN 1 .. v_ids.COUNT LOOP
    v_grades(i) := calculate_grade(v_marks(i));
  END LOOP;

  -- 3) ONE bulk statement updates all rows
  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments
       SET grade = v_grades(i)
     WHERE enrollment_id = v_ids(i);

  p_updated := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Bulk grading done. Rows read = ' || v_ids.COUNT || ' | rows updated = ' || p_updated);
EXCEPTION
  WHEN e_bulk_errors THEN
    v_failed  := SQL%BULK_EXCEPTIONS.COUNT;
    p_updated := v_ids.COUNT - v_failed;
    FOR j IN 1 .. v_failed LOOP
      DBMS_OUTPUT.PUT_LINE('  FAILED enrollment_id ' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) ||
                           ': ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    COMMIT;   -- keep the rows that worked
    log_error('GRADE_COURSE_BULK', -24381, v_failed || ' row(s) failed in bulk update');
    DBMS_OUTPUT.PUT_LINE('Bulk grading finished with errors. Updated = ' || p_updated || ' | failed = ' || v_failed);
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('GRADE_COURSE_BULK', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END grade_course_bulk;
/
SHOW ERRORS