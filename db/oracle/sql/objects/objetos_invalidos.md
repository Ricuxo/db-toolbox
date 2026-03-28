https://serhatcelik.wordpress.com/2021/05/27/how-to-find-why-and-when-a-object-became-invalid-in-oracle-database/

In a typical running application, you would not expect to see views or stored procedures become invalid, because applications typically do not change table structures or change view or stored procedure definitions during normal execution. Changes to tables, views, or PL/SQL units typically occur when an application is patched or upgraded using a patch script or ad-hoc DDL statements. Dependent objects might be left invalid after a patch has been applied to change a set of referenced objects.

The following are some general rules for the invalidation of schema objects:

i) Between a referenced object and each of its dependent objects, the database tracks the elements of the referenced object that are involved in the dependency. For example, if a single-table view selects only a subset of columns in a table, only those columns are involved in the dependency. For each dependent of an object, if a change is made to the definition of any element involved in the dependency (including dropping the element), the dependent object is invalidated. Conversely, if changes are made only to definitions of elements that are not involved in the dependency, the dependent object remains valid.

ii)  In many cases, therefore, developers can avoid invalidation of dependent objects and unnecessary extra work for the database if they exercise care when changing schema objects.

iii) Dependent objects are cascade invalidated. If any object becomes invalid for any reason, all of that object's dependent objects are immediately invalidated.

iv) If you revoke any object privileges on a schema object, dependent objects are cascade invalidated.

TO KNOW WHY AND WHEN OBJECT BECAME INVALID

DBA_DEPENDENCIES view can be used to check which objects depend on, then query DBA_OBJECTS to check the last_ddl_time for each of these dependant objects – that should give you an indication of which objects have changed and caused to be invalid as a result. Below SQLs can be used for investigation.

/* FIND ALL DEPENDENCY OF SPECIFIC OBJECT */
SELECT *
FROM DBA_DEPENDENCIES DP
WHERE DP.REFERENCED_OWNER NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
AND DP.REFERENCED_TYPE != 'NON-EXISTENT'
AND DP.NAME = 'TYPE_YOUR_INVALIDATED_OBJECT_NAME'

/* FIND ALL DEPENDENCY OF SPECIFIC OBJECT HAS NOT DBLINK */
SELECT *
FROM DBA_DEPENDENCIES DP
WHERE DP.REFERENCED_OWNER NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
AND DP.REFERENCED_TYPE != 'NON-EXISTENT'
AND DP.REFERENCED_LINK_NAME IS NULL
AND DP.NAME = 'TYPE_YOUR_INVALIDATED_OBJECT_NAME'

/* CHECK LAST_DDL_TIME OF DEPENDENT OBJECTS BELONG TO SPECIFIC OBJECT HAS NOT DBLINK */
SELECT DISTINCT DO.OWNER,
DO.OBJECT_TYPE,
DO.OBJECT_NAME,
DO.CREATED,
DO.LAST_DDL_TIME
FROM DBA_DEPENDENCIES DP, DBA_OBJECTS DO
WHERE DP.REFERENCED_OWNER = DO.OWNER
AND DP.REFERENCED_NAME = DO.OBJECT_NAME
AND DP.REFERENCED_OWNER NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
AND DP.REFERENCED_TYPE != 'NON-EXISTENT'
AND DP.REFERENCED_LINK_NAME IS NULL
AND DP.NAME = 'TYPE_YOUR_INVALIDATED_OBJECT_NAME'
ORDER BY DO.LAST_DDL_TIME DESC

/* CHECK DBA_AUDIT_TRAIL TO FIND WHO RUN DDL COMMAND ON DEPENDENT OBJECTS */
SELECT *
FROM DBA_AUDIT_TRAIL DT
WHERE TIMESTAMP BETWEEN TO_DATE ('24/05/2021 23:00:00′,
'DD/MM/YYYY HH24:MI:SS')
AND TO_DATE ('24/05/2021 23:59:00′,
'DD/MM/YYYY HH24:MI:SS')
AND DT.OBJ_NAME IN
('TYPE_YOUR_OBJECT_NAME_RESULT_OF_ABOVE_SQL')
ORDER BY 5

/* FIND ALL DEPENDENCY OF SPECIFIC OBJECT HAS DBLINK */
SELECT *
FROM DBA_DEPENDENCIES DP
WHERE DP.REFERENCED_OWNER NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
AND DP.REFERENCED_TYPE != 'NON-EXISTENT'
AND DP.REFERENCED_LINK_NAME IS NOT NULL
AND DP.NAME = 'TYPE_YOUR_INVALIDATED_OBJECT_NAME'

/* CHECK LAST_DDL_TIME OF DEPENDENT OBJECTS BELONG TO SPECIFIC OBJECT HAS DBLINK */
SELECT DISTINCT DO.OWNER,
DO.OBJECT_TYPE,
DO.OBJECT_NAME,
DO.CREATED,
DO.LAST_DDL_TIME
FROM DBA_DEPENDENCIES DP, DBA_OBJECTS@WRITE_YOUR_DB_LINK_NAME.WORLD DO
WHERE DP.REFERENCED_OWNER = DO.OWNER
AND DP.REFERENCED_NAME = DO.OBJECT_NAME
AND DP.REFERENCED_OWNER NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
AND DP.REFERENCED_TYPE != 'NON-EXISTENT'
AND DP.REFERENCED_LINK_NAME IS NOT NULL
AND DP.NAME = 'TYPE_YOUR_INVALIDATED_OBJECT_NAME'
ORDER BY DO.LAST_DDL_TIME DESC

/* CHECK DBA_AUDIT_TRAIL TO FIND WHO RUN DDL COMMAND ON DEPENDENT OBJECTS.
RUN THIS COMMAND ON THE DBLINK SOURCE DB */
SELECT *
FROM DBA_AUDIT_TRAIL DT
WHERE TIMESTAMP BETWEEN TO_DATE ('24/05/2021 23:00:00′,
'DD/MM/YYYY HH24:MI:SS')
AND TO_DATE ('24/05/2021 23:59:00′,
'DD/MM/YYYY HH24:MI:SS')
AND DT.OBJ_NAME IN
('TYPE_YOUR_OBJECT_NAME_RESULT_OF_ABOVE_SQL')
ORDER BY 5