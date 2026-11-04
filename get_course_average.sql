CREATE OR REPLACE FUNCTION get_course_average (
  p_course_id IN NUMBER,
  p_semester  IN VARCHAR2
) RETURN NUMBER
IS
  v_course courses%ROWTYPE;
  v_avg    NUMBER;
BEGIN
  SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;

  SELECT AVG(marks)
    INTO v_avg
    FROM enrollments
   WHERE course_id = p_course_id
     AND semester  = p_semester;

  IF v_avg IS NULL THEN
    RAISE_APPLICATION_ERROR(-20006, 'No marks recorded yet for ' || v_course.course_code || ' in ' || p_semester || '.');
  END IF;

  RETURN ROUND(v_avg, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20007, 'Course ' || p_course_id || ' does not exist.');
END get_course_average;
/
SHOW ERRORS