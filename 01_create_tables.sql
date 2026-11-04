SET SERVEROUTPUT ON;

-- Clean start (safe to re-run)
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('ERROR_LOG','PERF_TEST','GRADE_AUDIT',
                                 'ENROLLMENTS','COURSES','STUDENTS','DEPARTMENTS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN ('SEQ_STUDENT','SEQ_ENROLLMENT','SEQ_AUDIT','SEQ_ERROR')) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

CREATE SEQUENCE seq_student    START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_enrollment START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_audit      START WITH 1   INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_error      START WITH 1   INCREMENT BY 1 NOCACHE;

CREATE TABLE departments (
  dept_id    NUMBER        PRIMARY KEY,
  dept_name  VARCHAR2(60)  NOT NULL UNIQUE
);

CREATE TABLE students (
  student_id   NUMBER        PRIMARY KEY,
  first_name   VARCHAR2(50)  NOT NULL,
  last_name    VARCHAR2(50)  NOT NULL,
  email        VARCHAR2(100) NOT NULL UNIQUE,
  dept_id      NUMBER        NOT NULL REFERENCES departments(dept_id),
  enroll_date  DATE          DEFAULT SYSDATE NOT NULL,
  status       VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL,
  CONSTRAINT chk_student_status CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED'))
);

CREATE TABLE courses (
  course_id     NUMBER        PRIMARY KEY,
  course_code   VARCHAR2(15)  NOT NULL UNIQUE,
  course_title  VARCHAR2(100) NOT NULL,
  credits       NUMBER(2)     NOT NULL,
  dept_id       NUMBER        NOT NULL REFERENCES departments(dept_id),
  CONSTRAINT chk_course_credits CHECK (credits BETWEEN 1 AND 6)
);

CREATE TABLE enrollments (
  enrollment_id  NUMBER       PRIMARY KEY,
  student_id     NUMBER       NOT NULL REFERENCES students(student_id),
  course_id      NUMBER       NOT NULL REFERENCES courses(course_id),
  semester       VARCHAR2(10) NOT NULL,
  marks          NUMBER(5,2),
  grade          VARCHAR2(2),
  CONSTRAINT chk_marks_range CHECK (marks BETWEEN 0 AND 100),
  CONSTRAINT uq_enrollment   UNIQUE (student_id, course_id, semester)
);

-- History of mark changes (no foreign key on purpose)
CREATE TABLE grade_audit (
  audit_id       NUMBER       PRIMARY KEY,
  enrollment_id  NUMBER       NOT NULL,
  old_marks      NUMBER(5,2),
  new_marks      NUMBER(5,2),
  changed_on     DATE         DEFAULT SYSDATE NOT NULL
);

-- Unexpected errors are saved here
CREATE TABLE error_log (
  log_id      NUMBER        PRIMARY KEY,
  proc_name   VARCHAR2(60),
  error_code  NUMBER,
  error_msg   VARCHAR2(500),
  logged_on   DATE          DEFAULT SYSDATE NOT NULL
);

-- Only for the performance demo
CREATE TABLE perf_test (
  id   NUMBER,
  val  VARCHAR2(50)
);

PROMPT Tables and sequences created.