-----------------------------------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;
CREATE DATABASE SNOWFLAKE_SAMPLE_DATA FROM SHARE SFC_SAMPLES.SAMPLE_DATA;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE PUBLIC;
-----------------------------------------------------------------------------------------------------

USE ROLE DATAHUB_ROLE;
CREATE SCHEMA IF NOT EXISTS DATAHUB;
USE SCHEMA ADM_SNOWFLAKE.DATAHUB;
CREATE IMAGE REPOSITORY IF NOT EXISTS DATAHUB_REPOSITORY;
CREATE STAGE IF NOT EXISTS SERVICE_SPEC DIRECTORY = ( ENABLE = TRUE );

CREATE OR REPLACE TABLE ADM_SNOWFLAKE.DATAHUB.DATABASE_CONTROL (
    DATABASE_NAME VARCHAR UNIQUE,    -- DATABASE´S NAME
    PROCESSED BOOLEAN DEFAULT FALSE, -- PROCEDURE HAS DONE
    LAST_PROCESSED_AT TIMESTAMP_LTZ  -- LAST EXECUTION
);

----------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE ADM_SNOWFLAKE.DATAHUB.GRANT_DATAHUB_PERMISSIONS(database_name VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
BEGIN
    -- Grant access to view database and schema
    GRANT USAGE ON DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT USAGE ON FUTURE SCHEMAS IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;

    -- Grant Select access enable Data Profiling
    GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON FUTURE TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON ALL EXTERNAL TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON FUTURE EXTERNAL TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON ALL VIEWS IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON FUTURE VIEWS IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON ALL DYNAMIC TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT SELECT ON FUTURE DYNAMIC TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;

    -- Grant access to view tables and views (REFERENCES)
    GRANT REFERENCES ON ALL TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT REFERENCES ON FUTURE TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT REFERENCES ON ALL EXTERNAL TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT REFERENCES ON FUTURE EXTERNAL TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT REFERENCES ON ALL VIEWS IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT REFERENCES ON FUTURE VIEWS IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;

    -- Grant access to dynamic tables (MONITOR)
    GRANT MONITOR ON ALL DYNAMIC TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;
    GRANT MONITOR ON FUTURE DYNAMIC TABLES IN DATABASE IDENTIFIER(:database_name) TO ROLE datahub_role;

    RETURN 'Permissions granted successfully for database: ' || database_name;
END;
;

CREATE OR REPLACE PROCEDURE ADM_SNOWFLAKE.DATAHUB.DAILY_GRANT_PERMISSIONS_PROCESS()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS

DECLARE
    res_databases RESULTSET := (SELECT DATABASE_NAME AS "name", * 
    FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES WHERE TYPE = 'STANDARD' AND DELETED IS NULL);
    cur_databases CURSOR FOR res_databases;
    database_name VARCHAR;
    processed_flag BOOLEAN;
BEGIN
    FOR rec IN cur_databases DO
        database_name := rec."name";

        SELECT processed INTO processed_flag
        FROM database_control
        WHERE database_name = :database_name;

        IF (processed_flag IS NULL OR processed_flag = FALSE) THEN
            CALL grant_datahub_permissions(:database_name);
            MERGE INTO database_control AS target
            USING (SELECT :database_name AS db_name) AS source
            ON (target.database_name = source.db_name)
            WHEN MATCHED THEN
                UPDATE SET processed = TRUE, last_processed_at = CURRENT_TIMESTAMP()
            WHEN NOT MATCHED THEN
                INSERT (database_name, processed, last_processed_at)
                VALUES (:database_name, TRUE, CURRENT_TIMESTAMP());
        ELSE
            SELECT 'Database "' || :database_name || '" already done' AS message;
        END IF;
    END FOR;

    RETURN 'Validation and check grants complete.';
END;

CALL ADM_SNOWFLAKE.DATAHUB.DAILY_GRANT_PERMISSIONS_PROCESS();

-- CREATE A NEW DATABASE JUST RUN PROCEDURE AGAIN OR CREATE A TASK FOR IT

CREATE OR REPLACE TASK ADM_SNOWFLAKE.DATAHUB.DAILY_GRANT_PERMISSIONS_TASK
    WAREHOUSE = WH_DEV
    SCHEDULE = 'USING CRON 0 6 * * * UTC'
AS
BEGIN
    CALL ADM_SNOWFLAKE.DATAHUB.DAILY_GRANT_PERMISSIONS_PROCESS();
END;