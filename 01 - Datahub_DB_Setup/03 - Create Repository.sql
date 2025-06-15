---------------------------------------------------------------------------------------------------
USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA ADM_SNOWFLAKE.DATAHUB;
CREATE IMAGE REPOSITORY IF NOT EXISTS DATAHUB_REPOSITORY;
CREATE STAGE IF NOT EXISTS SERVICE_SPEC DIRECTORY = ( ENABLE = TRUE );

----------------------------------------------------------------------------------------------------------------
SHOW IMAGE REPOSITORIES;
SHOW IMAGES IN IMAGE REPOSITORY DATAHUB_REPOSITORY;

-- gxktfis-datahub-dev.registry.snowflakecomputing.com/adm_snowflake/datahub/datahub_repository