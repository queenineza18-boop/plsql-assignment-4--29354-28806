# Implementation and Performance Notes

## Design
- Tables: departments -> students -> enrollments <- courses. grade_audit keeps mark history,
  error_log keeps unexpected errors, perf_test is only for the speed test.
- Constraints: primary keys, foreign keys, UNIQUE (email, course code, one enrollment per
  student/course/semester), CHECK (marks 0-100, credits 1-6, student status).
- Procedures change data. Functions only calculate and return values.

## Exception handling
- Known problems raise clear messages with RAISE_APPLICATION_ERROR (codes -20001 to -20080).
- Every procedure ends with WHEN OTHERS: it rolls back, saves the error in error_log
  (log_error, an autonomous transaction) and then re-raises it with RAISE.
- Functions never return a fake value (like 0). They raise an error instead.

## Bulk processing and performance
A normal loop sends each INSERT/UPDATE to the SQL engine one row at a time. Every call is a
context switch between the PL/SQL engine and the SQL engine, which is slow for many rows.
- BULK COLLECT reads all rows with one switch.
- FORALL sends all DML with one switch.
- SAVE EXCEPTIONS lets FORALL continue after a bad row. Failed rows are in
  SQL%BULK_EXCEPTIONS and ORA-24381 is handled with PRAGMA EXCEPTION_INIT.

Our measurement (performance_demo with 20000 rows):
| Method | Time |
|--------|------|
| Row-by-row loop | YOUR NUMBER seconds |
| FORALL bulk | YOUR NUMBER seconds |
| Result | Bulk was about YOUR NUMBER times faster |

For millions of rows, use BULK COLLECT ... LIMIT 1000 in a loop to save memory.

## Tests
- test_success_cases.sql: 10 successful scenarios.
- test_error_cases.sql: 17 error scenarios, including bulk DML errors.
- Screenshots are in screenshots/.