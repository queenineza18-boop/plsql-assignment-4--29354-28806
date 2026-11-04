CREATE OR REPLACE PROCEDURE add_bonus_marks_bulk (
  p_course_id IN  NUMBER,
  p_semester  IN  VARCHAR2,
  p_bonus     IN  NUMBER,
  p_updated   OUT NUMBER,
  p_failed    OUT NUMBER
)
IS
  TYPE t_id_tab IS TABLE OF enrollments.enrollment_id%TYPE INDEX BY PLS_INTEGER;  -- associative array
  v_ids t_id_tab;

  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
BEGIN
  IF p_bonus IS NULL OR p_bonus < 1 OR p_bonus > 20 THEN
    RAISE_APPLICATION_ERROR(-20070, 'Bonus must be between 1 and 20 marks.');
  END IF;

  SELECT enrollment_id
    BULK COLLECT INTO v_ids
    FROM enrollments
   WHERE course_id = p_course_id
     AND semester  = p_semester
     AND marks IS NOT NULL;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20071, 'No marked enrollments found for course ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  -- grade is cleared so you can re-grade with grade_course_bulk
  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments
       SET marks = marks + p_bonus,
           grade = NULL
     WHERE enrollment_id = v_ids(i);

  p_updated := SQL%ROWCOUNT;
  p_failed  := 0;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Bonus of ' || p_bonus || ' added. Rows updated = ' || p_updated || ' | failed = 0');
EXCEPTION
  WHEN e_bulk_errors THEN
    p_failed  := SQL%BULK_EXCEPTIONS.COUNT;
    p_updated := v_ids.COUNT - p_failed;
    FOR j IN 1 .. p_failed LOOP
      DBMS_OUTPUT.PUT_LINE('  FAILED enrollment_id ' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) ||
                           ': ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    COMMIT;   -- keep the rows that worked
    DBMS_OUTPUT.PUT_LINE('Bonus of ' || p_bonus || ' added with errors. Updated = ' || p_updated || ' | failed = ' || p_failed);
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('ADD_BONUS_MARKS_BULK', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END add_bonus_marks_bulk;
/
SHOW ERRORS