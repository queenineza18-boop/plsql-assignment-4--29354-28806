CREATE OR REPLACE PROCEDURE update_marks (
  p_enrollment_id IN NUMBER,
  p_new_marks     IN NUMBER
)
IS
  v_enrollment enrollments%ROWTYPE;                -- %ROWTYPE record

  TYPE t_mark_change IS RECORD (                   -- user-defined record
    old_marks enrollments.marks%TYPE,
    new_marks enrollments.marks%TYPE,
    new_grade enrollments.grade%TYPE
  );
  v_change t_mark_change;
  v_rows   PLS_INTEGER;
BEGIN
  IF p_new_marks IS NULL OR p_new_marks < 0 OR p_new_marks > 100 THEN
    RAISE_APPLICATION_ERROR(-20030, 'Marks must be a number between 0 and 100.');
  END IF;

  BEGIN
    SELECT * INTO v_enrollment FROM enrollments WHERE enrollment_id = p_enrollment_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20031, 'Enrollment ' || p_enrollment_id || ' does not exist.');
  END;

  v_change.old_marks := v_enrollment.marks;
  v_change.new_marks := p_new_marks;
  v_change.new_grade := calculate_grade(p_new_marks);

  UPDATE enrollments
     SET marks = v_change.new_marks,
         grade = v_change.new_grade
   WHERE enrollment_id = p_enrollment_id;

  v_rows := SQL%ROWCOUNT;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20032, 'Update failed: no row changed for enrollment ' || p_enrollment_id || '.');
  END IF;

  INSERT INTO grade_audit (audit_id, enrollment_id, old_marks, new_marks)
  VALUES (seq_audit.NEXTVAL, p_enrollment_id, v_change.old_marks, v_change.new_marks);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Marks updated: ' || NVL(TO_CHAR(v_change.old_marks), 'none') ||
                       ' -> ' || v_change.new_marks ||
                       ' | grade = ' || v_change.new_grade ||
                       ' | rows updated = ' || v_rows);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('UPDATE_MARKS', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END update_marks;
/
SHOW ERRORS