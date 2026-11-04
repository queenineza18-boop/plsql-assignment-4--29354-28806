CREATE OR REPLACE FUNCTION calculate_grade (p_marks IN NUMBER)
RETURN VARCHAR2
DETERMINISTIC
IS
BEGIN
  IF p_marks IS NULL THEN
    RETURN NULL;
  END IF;

  IF p_marks < 0 OR p_marks > 100 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Marks must be between 0 and 100. Received: ' || p_marks);
  END IF;

  RETURN CASE
           WHEN p_marks >= 80 THEN 'A'
           WHEN p_marks >= 70 THEN 'B'
           WHEN p_marks >= 60 THEN 'C'
           WHEN p_marks >= 50 THEN 'D'
           ELSE 'F'
         END;
END calculate_grade;
/
SHOW ERRORS