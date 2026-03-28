col grantee format a30
col privilege format a100
col account_status format a30

SELECT GRANTEE,
       PRIVILEGE,
       ACCOUNT_STATUS
FROM   (SELECT GRANTEE,
               LTRIM(MAX(SYS_CONNECT_BY_PATH(PRIVILEGE, ', ')), ', ') PRIVILEGE
        FROM   (SELECT GRANTEE,
                       PRIVILEGE,
                       ROW_NUMBER() OVER(PARTITION BY GRANTEE ORDER BY
PRIVILEGE) RN
                FROM   (SELECT DISTINCT NVL(A.GRANTEE, B.GRANTEE) GRANTEE,
                                        NVL(A.PRIVILEGE, B.PRIVILEGE) PRIVILEGE
                        FROM   (SELECT A.GRANTEE,
                                       A.PATH PRIVILEGE
                                FROM   (SELECT A.GRANTEE,
                                               A.GRANTED_ROLE_ROOT PRIVILEGE,
                                               A.PATH,
                                               A.NIVEL,
                                               RANK() OVER(PARTITION
BY A.GRANTEE, A.FIRST_ROLE ORDER BY NIVEL ASC) RANK
                                        FROM   (SELECT A.GRANTEE,
                                                       GRANTED_ROLE FIRST_ROLE,
                                                       CONNECT_BY_ROOT
GRANTED_ROLE GRANTED_ROLE_ROOT,
                                                       '(' ||
LTRIM(SYS_CONNECT_BY_PATH(GRANTED_ROLE, '->'), '->') || ')' PATH,
                                                       LEVEL NIVEL
                                                FROM   DBA_ROLE_PRIVS A
                                                CONNECT BY PRIOR
GRANTEE = GRANTED_ROLE) A,
                                               DBA_SYS_PRIVS B
                                        WHERE  A.GRANTEE NOT IN (SELECT ROLE
                                                                 FROM
 DBA_ROLES)
                                        AND    A.GRANTED_ROLE_ROOT = B.GRANTEE
                                        AND    (B.PRIVILEGE LIKE 'DROP
ANY%' OR B.PRIVILEGE LIKE 'GRANT%' OR B.PRIVILEGE IN ('ADMINISTER
DATABASE TRIGGER'))) A
                                WHERE  A.RANK = 1) A
                        FULL   OUTER JOIN (SELECT GRANTEE,
                                                 PRIVILEGE
                                          FROM   DBA_SYS_PRIVS
                                          WHERE  (PRIVILEGE LIKE 'DROP
ANY%' OR PRIVILEGE LIKE 'GRANT%' OR PRIVILEGE IN ('ADMINISTER DATABASE
TRIGGER'))
                                          AND    GRANTEE NOT IN (SELECT ROLE
                                                                 FROM
 DBA_ROLES)) B ON B.GRANTEE = A.GRANTEE))
        START  WITH RN = 1
        CONNECT BY PRIOR RN = RN - 1
            AND    PRIOR GRANTEE = GRANTEE
        GROUP  BY GRANTEE) A,
       DBA_USERS B
WHERE  A.GRANTEE = B.USERNAME
ORDER  BY 1;

prompt Usuarios no v$pwfile_users;

select * from v$pwfile_users;