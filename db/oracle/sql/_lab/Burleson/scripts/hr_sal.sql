/*  */
CREATE TABLE sal AS SELECT empno, sal,comm FROM EMP;

ALTER TABLE sal ADD hr_usage VARCHAR2(12);

UPDATE sal SET hr_usage='RESTRICTED';

COMMIT;
