# Student Registration and Grading System (Oracle PL/SQL)

Course: Database Development with PL/SQL (INSY 8311) - Group Assignment IV

## Group members
| Full name | Student ID |
|-----------|------------|
| Quee Ineza| 29354 |
| Ihirwe Benie | 28806 |

## Application description
A university system that registers students, enrolls them in courses, stores marks,
and calculates letter grades and GPA.

Requirements:
1. Register students (unique email, valid department).
2. Enroll only ACTIVE students, never twice in the same course and semester.
3. Update marks with automatic grade calculation and an audit trail.
4. Delete an enrollment only if it is not graded yet.
5. Grade a class and add bonus marks using bulk processing.
6. Print transcripts, class reports and GPA.
7. Log unexpected errors in a table.

## Tables
departments, students, courses, enrollments, grade_audit, error_log, perf_test
(see 00_schema/01_create_tables.sql for keys and constraints).

## How to run
1. 00_schema/01_create_tables.sql
2. 00_schema/02_insert_sample_data.sql
3. 00_schema/03_create_types.sql
4. All files in 02_functions/ (functions first, because procedures call them)
5. All files in 01_procedures/ (start with log_error.sql)
6. 03_tests/test_success_cases.sql
7. 03_tests/test_error_cases.sql
8. Check screenshots/

## Where each concept is used
| Concept | Where |
|---------|-------|
| User-defined records | update_marks, print_transcript, class_report |
| %ROWTYPE | enroll_student, update_marks, get_course_average |
| Associative array | class_report, add_bonus_marks_bulk, performance_demo |
| Nested table | class_report, grade_course_bulk |
| VARRAY | get_top_students |
| Implicit cursors | register_student, enroll_student, update_marks, delete_enrollment |
| Explicit cursors | print_transcript (OPEN/FETCH/CLOSE), class_report and calculate_gpa (FOR loop) |
| BULK COLLECT / FORALL | grade_course_bulk, add_bonus_marks_bulk, performance_demo |
| Predefined exceptions | NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX |
| User-defined exceptions, RAISE_APPLICATION_ERROR | all procedures and functions |
