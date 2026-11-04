CREATE OR REPLACE PROCEDURE delete_enrollment (p_enrollment_id IN NUMBER)
IS
  v_grade enrollments.grade%TYPE;
  e_already_graded EXCEPTION;                      -- user-defined exception
BEGIN
  BEGIN
    SELECT grade INTO v_grade FROM enrollments WHERE enrollment_id = p_enrollment_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20040, 'Enrollment ' || p_enrollment_id || ' does not exist.');
  END;

  IF v_grade IS NOT NULL THEN
    RAISE e_already_graded;
  END IF;

  DELETE FROM enrollments WHERE enrollment_id = p_enrollment_id;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Enrollment ' || p_enrollment_id || ' deleted | rows deleted = ' || SQL%ROWCOUNT);
    COMMIT;
  ELSE
    RAISE_APPLICATION_ERROR(-20042, 'Nothing was deleted for enrollment ' || p_enrollment_id || '.');
  END IF;
EXCEPTION
  WHEN e_already_graded THEN
    RAISE_APPLICATION_ERROR(-20041, 'Enrollment ' || p_enrollment_id || ' already has grade ' || v_grade || ' and cannot be deleted.');
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('DELETE_ENROLLMENT', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END delete_enrollment;
/
SHOW ERRORS