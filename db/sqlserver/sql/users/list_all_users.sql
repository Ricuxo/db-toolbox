-- ============================================================
-- Inventário completo: Logins x Usuários x Roles x Databases
-- ============================================================
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#usuarios') IS NOT NULL DROP TABLE #usuarios;

CREATE TABLE #usuarios (
    instance_name       NVARCHAR(128),
    database_name       NVARCHAR(128),
    user_name           NVARCHAR(128),
    user_type           NVARCHAR(60),
    mapped_login        NVARCHAR(128),
    login_type          NVARCHAR(60),
    login_disabled      BIT,
    default_schema      NVARCHAR(128),
    db_roles            NVARCHAR(MAX),
    user_create_date    DATETIME,
    user_modify_date    DATETIME
);

DECLARE @sql NVARCHAR(MAX);
DECLARE @db  NVARCHAR(128);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT name 
    FROM sys.databases
    WHERE state_desc = 'ONLINE'          -- apenas DBs online
      AND name NOT IN ('tempdb');        -- tempdb não faz sentido auditar

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
    USE ' + QUOTENAME(@db) + N';

    INSERT INTO #usuarios
    SELECT 
        @@SERVERNAME,
        DB_NAME(),
        dp.name,
        dp.type_desc,
        ISNULL(sp.name, ''** SEM LOGIN MAPEADO **''),
        ISNULL(sp.type_desc, ''N/A''),
        ISNULL(sp.is_disabled, 0),
        ISNULL(dp.default_schema_name, ''dbo''),
        STUFF((
            SELECT '', '' + r.name
            FROM sys.database_role_members rm
            JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
            WHERE rm.member_principal_id = dp.principal_id
            FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 2, ''''
        ),
        dp.create_date,
        dp.modify_date
    FROM sys.database_principals dp
    LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
    WHERE dp.type NOT IN (''R'')              -- exclui roles
      AND dp.name NOT IN (                    -- exclui contas de sistema
            ''dbo'', ''guest'', ''INFORMATION_SCHEMA'', ''sys'',
            ''##MS_PolicyEventProcessingLogin##'',
            ''##MS_AgentSigningCertificate##''
        );
    ';

    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao processar banco: ' + @db + ' | ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @db;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Resultado final
SELECT 
    instance_name,
    database_name,
    user_name,
    user_type,
    mapped_login,
    login_type,
    CASE login_disabled WHEN 1 THEN '⚠ DESABILITADO' ELSE 'Ativo' END AS login_status,
    default_schema,
    ISNULL(db_roles, 'Sem roles') AS db_roles,
    user_create_date,
    user_modify_date
FROM #usuarios
ORDER BY database_name, user_type, user_name;

-- DROP TABLE #usuarios;