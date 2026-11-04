INSERT INTO departments VALUES (1, 'Information Technology');
INSERT INTO departments VALUES (2, 'Business Administration');
INSERT INTO departments VALUES (3, 'Education');

INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (1,  'Eric',     'Mugisha',    'eric.mugisha@auca.test',      1, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (2,  'Aline',    'Uwase',      'aline.uwase@auca.test',       1, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (3,  'Jean',     'Niyonsenga', 'jean.niyonsenga@auca.test',   1, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (4,  'Grace',    'Ingabire',   'grace.ingabire@auca.test',    1, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (5,  'David',    'Habimana',   'david.habimana@auca.test',    2, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (6,  'Sandrine', 'Mukamana',   'sandrine.mukamana@auca.test', 2, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (7,  'Brenda',   'Uwase',      'brenda.uwase@auca.test',      2, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (8,  'Patrick',  'Nshuti',     'patrick.nshuti@auca.test',    1, 'SUSPENDED');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (9,  'Joel',     'Iradukunda', 'joel.iradukunda@auca.test',   3, 'ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, dept_id, status) VALUES (10, 'Claire',   'Umutoni',    'claire.umutoni@auca.test',    3, 'ACTIVE');

INSERT INTO courses VALUES (1, 'INSY8311', 'Database Development with PL/SQL', 3, 1);
INSERT INTO courses VALUES (2, 'INSY8222', 'Database Management Systems',      3, 1);
INSERT INTO courses VALUES (3, 'MATH8127', 'Digital Computer Fundamentals',    2, 1);
INSERT INTO courses VALUES (4, 'BUSA1101', 'Introduction to Business',         3, 2);
INSERT INTO courses VALUES (5, 'STAT1201', 'Descriptive Statistics',           2, 3);

-- Course 1: marks given, grades empty (the bulk procedure fills them)
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (1, 1, 1, '2026-S1', 85);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (2, 2, 1, '2026-S1', 72);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (3, 3, 1, '2026-S1', 64);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (4, 4, 1, '2026-S1', 91);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (5, 5, 1, '2026-S1', 58);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (6, 6, 1, '2026-S1', 47);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (7, 7, 1, '2026-S1', 78);
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, marks) VALUES (8, 8, 1, '2026-S1', 69);
-- Course 2 and 3: already graded
INSERT INTO enrollments VALUES (9,  1, 2, '2026-S1', 77, 'B');
INSERT INTO enrollments VALUES (10, 2, 2, '2026-S1', 88, 'A');
INSERT INTO enrollments VALUES (11, 3, 2, '2026-S1', 53, 'D');
INSERT INTO enrollments VALUES (12, 4, 2, '2026-S1', 95, 'A');
INSERT INTO enrollments VALUES (13, 5, 2, '2026-S1', 66, 'C');
INSERT INTO enrollments VALUES (14, 1, 3, '2026-S1', 62, 'C');
INSERT INTO enrollments VALUES (15, 3, 3, '2026-S1', 81, 'A');
INSERT INTO enrollments VALUES (16, 6, 3, '2026-S1', 45, 'F');
-- Course 4 and 5: no marks yet
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester) VALUES (17, 9,  4, '2026-S1');
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester) VALUES (18, 10, 4, '2026-S1');
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester) VALUES (19, 9,  5, '2026-S1');
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester) VALUES (20, 10, 5, '2026-S1');
INSERT INTO enrollments (enrollment_id, student_id, course_id, semester) VALUES (21, 7,  5, '2026-S1');

COMMIT;

SELECT 'departments' AS table_name, COUNT(*) AS total_rows FROM departments UNION ALL
SELECT 'students',    COUNT(*) FROM students    UNION ALL
SELECT 'courses',     COUNT(*) FROM courses     UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments;