SET SERVEROUTPUT ON;

PROMPT ===== ERROR 1: invalid email (user-defined exception) =====
DECLARE v_id NUMBER;
BEGIN
  register_student('Bad', 'Email', 'no-at-sign', 1, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 2: duplicate email (DUP_VAL_ON_INDEX) =====
DECLARE v_id NUMBER;
BEGIN
  register_student('Aline', 'Copy', 'aline.uwase@auca.test', 1, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 3: department does not exist =====
DECLARE v_id NUMBER;
BEGIN
  register_student('Lost', 'Dept', 'lost.dept@auca.test', 99, v_id);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 4: student does not exist (NO_DATA_FOUND) =====
DECLARE v_enr NUMBER;
BEGIN
  enroll_student(999, 1, '2026-S2', v_enr);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 5: suspended student =====
DECLARE v_enr NUMBER;
BEGIN
  enroll_student(8, 2, '2026-S2', v_enr);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 6: already enrolled =====
DECLARE v_enr NUMBER;
BEGIN
  enroll_student(1, 1, '2026-S1', v_enr);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 7: bad marks, and enrollment that does not exist =====
BEGIN
  update_marks(1, 150);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/
BEGIN
  update_marks(9999, 60);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 8: delete graded enrollment, and one that does not exist =====
BEGIN
  delete_enrollment(9);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/
BEGIN
  delete_enrollment(9999);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 9: NO_DATA_FOUND inside functions =====
BEGIN
  DBMS_OUTPUT.PUT_LINE(get_student_name(9999));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/
BEGIN
  DBMS_OUTPUT.PUT_LINE(find_student_by_lastname('Zzzz'));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 10: TOO_MANY_ROWS (two students are called Uwase) =====
BEGIN
  DBMS_OUTPUT.PUT_LINE(find_student_by_lastname('Uwase'));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 11: invalid marks in calculate_grade =====
BEGIN
  DBMS_OUTPUT.PUT_LINE(calculate_grade(120));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 12: GPA for a student with no grades =====
BEGIN
  DBMS_OUTPUT.PUT_LINE(calculate_gpa(9));
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 13: report and bulk grading with nothing to process =====
BEGIN
  class_report(99, '2026-S1');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/
DECLARE v_n NUMBER;
BEGIN
  grade_course_bulk(4, '2026-S1', v_n);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 14: BULK DML ERRORS (bonus of 15 pushes some marks above 100) =====
DECLARE
  v_updated NUMBER;
  v_failed  NUMBER;
BEGIN
  add_bonus_marks_bulk(1, '2026-S1', 15, v_updated, v_failed);
  DBMS_OUTPUT.PUT_LINE('Handled bulk errors -> updated = ' || v_updated || ', failed = ' || v_failed);
END;
/

PROMPT ===== ERROR 15: invalid bonus value =====
DECLARE
  v_updated NUMBER;
  v_failed  NUMBER;
BEGIN
  add_bonus_marks_bulk(1, '2026-S1', 50, v_updated, v_failed);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 16: invalid row count in performance_demo =====
BEGIN
  performance_demo(0);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== ERROR 17: unexpected database error (child records exist) =====
BEGIN
  DELETE FROM students WHERE student_id = 1;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected error caught -> ' || SQLERRM);
END;
/

PROMPT ===== Errors saved by log_error =====
SELECT log_id, proc_name, error_code, error_msg FROM error_log ORDER BY log_id;