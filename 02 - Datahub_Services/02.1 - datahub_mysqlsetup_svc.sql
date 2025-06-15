USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_mysqlsetup_svc
  IN COMPUTE POOL DATAHUB_POOL
  FROM SPECIFICATION $$
    spec:
      containers:
      - name: mysqlsetup
        image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-mysql-setup:head
        env: 
            MYSQL_USERNAME: datahub
            MYSQL_PASSWORD: datahub
            DATAHUB_DB_NAME: datahub
            MYSQL_PORT: 3306
            MYSQL_HOST: datahub-mysql-svc.ejmu.svc.spcs.internal
      $$
      
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

-- AFTER Completed successfully
DROP SERVICE datahub_mysqlsetup_svc;

/*
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_mysqlsetup_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_mysqlsetup_svc', '0','mysqlsetup');
DROP SERVICE datahub_mysqlsetup_svc;
SHOW SERVICES;
*/