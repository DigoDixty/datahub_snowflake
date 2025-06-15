USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

DROP SERVICE datahub_schema_registry_svc;

CREATE SERVICE datahub_schema_registry_svc
  IN COMPUTE POOL DATAHUB_POOL
  FROM SPECIFICATION $$
    spec: 
      containers:
      - name: schemaregistry
        image: /adm_snowflake/datahub/datahub_repository/confluentinc/cp-schema-registry:7.4.0
        env:
            SCHEMA_REGISTRY_HOST_NAME: schemaregistry
            SCHEMA_REGISTRY_KAFKASTORE_SECURITY_PROTOCOL: PLAINTEXT
            SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: datahub-broker-svc.ejmu.svc.spcs.internal:29092

      endpoints:    
      - name: schemaregistry
        port: 8081
        public: true
        
      $$
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

/*
SHOW ENDPOINTS IN SERVICE datahub_schema_registry_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_schema_registry_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_schema_registry_svc', '0','schemaregistry');
SHOW SERVICES;
*/