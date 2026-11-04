CREATE OR REPLACE FUNCTION get_top_students (p_n IN NUMBER)
RETURN t_student_ids
IS
  v_ids t_student_ids;
BEGIN
  IF p_n IS NULL OR p_n < 1 OR p_n > 10 THEN
    RAISE_APPLICATION_ERROR(-20008, 'p_n must be between 1 and 10.');
  END IF;

  SELECT student_id
    BULK COLLECT INTO v_ids
    FROM (SELECT student_id, AVG(marks) AS avg_marks
            FROM enrollments
           WHERE marks IS NOT NULL
           GROUP BY student_id
           ORDER BY avg_marks DESC, student_id)
   WHERE ROWNUM <= p_n;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20009, 'No marks recorded yet, so there is no ranking.');
  END IF;

  RETURN v_ids;
END get_top_students;
/
SHOW ERRORS