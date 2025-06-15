USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_mysql_svc
  IN COMPUTE POOL DATAHUB_POOL
  FROM SPECIFICATION $$
    spec:
      containers:
      - name: mysql
        image: /adm_snowflake/datahub/datahub_repository/mariadb:10.5.8
        env: 
            MYSQL_DATABASE: datahub
            MYSQL_USER: datahub
            MYSQL_PASSWORD: datahub
            MYSQL_ROOT_PASSWORD: datahub
            DATAHUB_MAPPED_MYSQL_PORT: 3306
            MYSQL_ROOT_HOST: "%"
        volumeMounts:
        - name: block-msql
          mountPath: /var/lib/mysql

      volumes:
      - name: block-msql
        source: block
        size: 100Gi

      endpoints:
      - name: mysql
        port: 3306
        public: true
      $$
      
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

CREATE OR REPLACE SNAPSHOT snapshot_mysql_data
FROM SERVICE datahub_mysql_svc
VOLUME "block-msql"
INSTANCE 0
COMMENT='data volume to mysql';

/*
ALTER SERVICE datahub_mysql_svc SUSPEND;
ALTER SERVICE datahub_mysql_svc RESUME;
SHOW ENDPOINTS IN SERVICE datahub_mysql_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_mysql_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_mysql_svc', '0','mysql');
SHOW SERVICES;

DROP SERVICE datahub_mysql_svc FORCE;
*/