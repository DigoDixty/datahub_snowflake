USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_elasticsearchsetup_svc
IN COMPUTE POOL DATAHUB_POOL
FROM SPECIFICATION $$
    spec:
      containers:
      - name: elasticsearchsetup
        image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-elasticsearch-setup:head
        env:
            ELASTICSEARCH_USE_SSL: false
            USE_AWS_ELASTICSEARCH: false
            ELASTICSEARCH_HOST: datahub-elasticsearch-svc.ejmu.svc.spcs.internal
            ELASTICSEARCH_PORT: 9200
            ELASTICSEARCH_PROTOCOL: http
      $$
      
MIN_INSTANCES=1
MAX_INSTANCES=1;

-- after Completed successfully
DROP SERVICE datahub_elasticsearchsetup_svc;


/*
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_elasticsearchsetup_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_elasticsearchsetup_svc', '0','elasticsearchsetup');
DROP SERVICE datahub_elasticsearchsetup_svc;
SHOW SERVICES;
*/