CREATE OR REPLACE PROCEDURE performance_demo (p_rows IN PLS_INTEGER DEFAULT 10000)
IS
  TYPE t_id_tab  IS TABLE OF perf_test.id%TYPE  INDEX BY PLS_INTEGER;
  TYPE t_val_tab IS TABLE OF perf_test.val%TYPE INDEX BY PLS_INTEGER;
  v_ids   t_id_tab;
  v_vals  t_val_tab;
  v_start PLS_INTEGER;
  v_row_time  PLS_INTEGER;   -- in 1/100 seconds
  v_bulk_time PLS_INTEGER;
BEGIN
  IF p_rows IS NULL OR p_rows < 1 OR p_rows > 100000 THEN
    RAISE_APPLICATION_ERROR(-20080, 'p_rows must be between 1 and 100000.');
  END IF;

  FOR i IN 1 .. p_rows LOOP
    v_ids(i)  := i;
    v_vals(i) := 'Row number ' || i;
  END LOOP;

  DELETE FROM perf_test;

  -- A) Row-by-row: one SQL call per row
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP
    INSERT INTO perf_test (id, val) VALUES (v_ids(i), v_vals(i));
  END LOOP;
  v_row_time := DBMS_UTILITY.GET_TIME - v_start;

  DELETE FROM perf_test;

  -- B) Bulk: ONE SQL call for all rows
  v_start := DBMS_UTILITY.GET_TIME;
  FORALL i IN 1 .. p_rows
    INSERT INTO perf_test (id, val) VALUES (v_ids(i), v_vals(i));
  v_bulk_time := DBMS_UTILITY.GET_TIME - v_start;

  DELETE FROM perf_test;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Rows inserted each way : ' || p_rows);
  DBMS_OUTPUT.PUT_LINE('Row-by-row time        : ' || v_row_time  / 100 || ' seconds');
  DBMS_OUTPUT.PUT_LINE('Bulk (FORALL) time     : ' || v_bulk_time / 100 || ' seconds');
  IF v_bulk_time > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Bulk was about ' || ROUND(v_row_time / v_bulk_time, 1) || ' times faster.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Bulk was too fast to measure. Try a bigger number of rows.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      log_error('PERFORMANCE_DEMO', SQLCODE, SQLERRM);
    END IF;
    RAISE;
END performance_demo;
/
SHOW ERRORS