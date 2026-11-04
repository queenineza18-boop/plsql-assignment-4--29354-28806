CREATE OR REPLACE PROCEDURE log_error (
  p_proc_name  IN VARCHAR2,
  p_error_code IN NUMBER,
  p_error_msg  IN VARCHAR2
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO error_log (log_id, proc_name, error_code, error_msg)
  VALUES (seq_error.NEXTVAL, p_proc_name, p_error_code, SUBSTR(p_error_msg, 1, 500));
  COMMIT;
END log_error;
/
SHOW ERRORS