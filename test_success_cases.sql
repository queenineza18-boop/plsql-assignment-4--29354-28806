SET SERVEROUTPUT ON;

PROMPT ===== TEST 1: function calculate_grade called from SQL =====
SELECT enrollment_id, marks, calculate_grade(marks) AS letter_grade
  FROM enrollments
 WHERE course_id = 1
 ORDER BY enrollment_id;

PROMPT ===== TEST 2: register, enroll, update marks, delete enrollment =====
DECLARE
  v_student_id  NUMBER;
  v_enr_course4 NUMBER;
  v_enr_course1 NUMBER;
  v_email       VARCHAR2(100) := 'new.student' || TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3') || '@auca.test';
BEGIN
  register_student('Test', 'Student', v_email, 1, v_student_id);
  DBMS_OUTPUT.PUT_LINE('Name from function: ' || get_student_name(v_student_id));

  enroll_student(v_student_id, 4, '2026-S1', v_enr_course4);
  enroll_student(v_student_id, 1, '2026-S1', v_enr_course1);

  update_marks(v_enr_course1, 74);
  delete_enrollment(v_enr_course4);
END;
/

PROMPT ===== TEST 3: add_bonus_marks_bulk (bonus of 5, no failures) =====
DECLARE
  v_updated NUMBER;
  v_failed  NUMBER;
BEGIN
  add_bonus_marks_bulk(1, '2026-S1', 5, v_updated, v_failed);
END;
/

PROMPT ===== TEST 4: grade_course_bulk (BULK COLLECT + FORALL) =====
DECLARE
  v_updated NUMBER;
BEGIN
  grade_course_bulk(1, '2026-S1', v_updated);
  DBMS_OUTPUT.PUT_LINE('OUT parameter p_updated = ' || v_updated);
END;
/

PROMPT ===== TEST 5: print_transcript (explicit cursor) =====
BEGIN
  print_transcript(1);
END;
/

PROMPT ===== TEST 6: class_report (cursor FOR loop, nested table, associative array) =====
BEGIN
  class_report(1, '2026-S1');
END;
/

PROMPT ===== TEST 7: functions called from an anonymous block =====
DECLARE
  v_id NUMBER;
BEGIN
  v_id := find_student_by_lastname('Mugisha');
  DBMS_OUTPUT.PUT_LINE('find_student_by_lastname(Mugisha) = ' || v_id);
  DBMS_OUTPUT.PUT_LINE('get_student_name(' || v_id || ')           = ' || get_student_name(v_id));
  DBMS_OUTPUT.PUT_LINE('calculate_gpa(' || v_id || ')              = ' || calculate_gpa(v_id));
  DBMS_OUTPUT.PUT_LINE('get_course_average(1, 2026-S1)    = ' || get_course_average(1, '2026-S1'));
END;
/

PROMPT ===== TEST 8: get_top_students (VARRAY) used in SQL =====
SELECT s.student_id, s.first_name, s.last_name
  FROM TABLE(get_top_students(3)) t
  JOIN students s ON s.student_id = t.COLUMN_VALUE;

PROMPT ===== TEST 9: performance_demo (row-by-row vs FORALL) =====
BEGIN
  performance_demo(20000);
END;
/

PROMPT ===== TEST 10: audit trail =====
SELECT * FROM grade_audit ORDER BY audit_id;