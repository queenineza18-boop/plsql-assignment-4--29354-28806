CREATE OR REPLACE FUNCTION calculate_gpa (p_student_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_grades IS
    SELECT c.credits, e.grade
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.student_id = p_student_id
       AND e.grade IS NOT NULL;

  v_name           VARCHAR2(101);
  v_points         NUMBER;
  v_total_points   NUMBER := 0;
  v_total_credits  NUMBER := 0;
BEGIN
  v_name := get_student_name(p_student_id);

  FOR r IN c_grades LOOP
    v_points := CASE r.grade
                  WHEN 'A' THEN 4
                  WHEN 'B' THEN 3
                  WHEN 'C' THEN 2
                  WHEN 'D' THEN 1
                  ELSE 0
                END;
    v_total_points  := v_total_points  + v_points * r.credits;
    v_total_credits := v_total_credits + r.credits;
  END LOOP;

  IF v_total_credits = 0 THEN
    RAISE_APPLICATION_ERROR(-20005, v_name || ' has no graded courses yet.');
  END IF;

  RETURN ROUND(v_total_points / v_total_credits, 2);
END calculate_gpa;
/
SHOW ERRORS