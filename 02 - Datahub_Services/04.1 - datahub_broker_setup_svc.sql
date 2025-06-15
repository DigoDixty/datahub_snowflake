USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_broker_setup_svc
  IN COMPUTE POOL DATAHUB_POOL
  FROM SPECIFICATION $$
    spec:
      containers:
      - name: broker-setup
        image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-kafka-setup:head
        env:
            DATAHUB_PRECREATE_TOPICS: ${DATAHUB_PRECREATE_TOPICS:-false}
            KAFKA_BOOTSTRAP_SERVER: datahub-broker-svc.ejmu.svc.spcs.internal:29092
            KAFKA_ZOOKEEPER_CONNECT: datahub-zookeeper-svc.ejmu.svc.spcs.internal:2181
            USE_CONFLUENT_SCHEMA_REGISTRY: TRUE
      $$
      
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

/*
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_broker_setup_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_broker_setup_svc', '0','broker-setup');
SHOW SERVICES;
DROP SERVICE datahub_broker_setup_svc;
*/
