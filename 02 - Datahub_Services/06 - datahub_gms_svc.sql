USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_gms_svc
IN COMPUTE POOL DATAHUB_POOL
FROM SPECIFICATION $$
spec:
    containers:
    - name: datahub-gms
      image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-gms:head
      
      env:
          SERVER_PORT: 8080
          DATAHUB_SERVER_TYPE: quickstart
          DATAHUB_TELEMETRY_ENABLED: true
          DATAHUB_UPGRADE_HISTORY_KAFKA_CONSUMER_GROUP_ID: generic-duhe-consumer-job-client-gms
          EBEAN_DATASOURCE_DRIVER: com.mysql.jdbc.Driver
          EBEAN_DATASOURCE_HOST: datahub-mysql-svc.ejmu.svc.spcs.internal:3306
          EBEAN_DATASOURCE_USERNAME: datahub
          EBEAN_DATASOURCE_PASSWORD: datahub
          
          EBEAN_DATASOURCE_URL: jdbc:mysql://datahub-mysql-svc.ejmu.svc.spcs.internal:3306/datahub?verifyServerCertificate=false&useSSL=true&useUnicode=yes&characterEncoding=UTF-8
          
          ELASTICSEARCH_HOST: datahub-elasticsearch-svc.ejmu.svc.spcs.internal
          ELASTICSEARCH_INDEX_BUILDER_MAPPINGS_REINDEX: true
          ELASTICSEARCH_INDEX_BUILDER_SETTINGS_REINDEX: true
          ELASTICSEARCH_PORT: 9200
          
          ENTITY_REGISTRY_CONFIG_PATH: /datahub/datahub-gms/resources/entity-registry.yml
          ENTITY_SERVICE_ENABLE_RETENTION: true
          ES_BULK_REFRESH_POLICY: WAIT_UNTIL
          GRAPH_SERVICE_DIFF_MODE_ENABLED: true
          GRAPH_SERVICE_IMPL: elasticsearch
          
          JAVA_OPTS: -Xms1g -Xmx1g
          KAFKA_BOOTSTRAP_SERVER: datahub-broker-svc.ejmu.svc.spcs.internal:29092
          KAFKA_SCHEMAREGISTRY_URL: http://datahub-schema-registry-svc.ejmu.svc.spcs.internal:8081
          MAE_CONSUMER_ENABLED: true
          MCE_CONSUMER_ENABLED: true
          PE_CONSUMER_ENABLED: true
          UI_INGESTION_ENABLED: true
          
          # METADATA_SERVICE_AUTH_ENABLED: ${METADATA_SERVICE_AUTH_ENABLED:-false}
          # KAFKA_CONSUMER_STOP_ON_DESERIALIZATION_ERROR: ${KAFKA_CONSUMER_STOP_ON_DESERIALIZATION_ERROR:-true}
          KAFKA_CONSUMER_STOP_ON_DESERIALIZATION_ERROR: true
          METADATA_SERVICE_AUTH_ENABLED: false    

      command:
        - bash
        - -c
        - "/datahub/datahub-gms/scripts/start.sh"
          
    endpoints:
    - name: datahub-gms
      port: 8080
      public: true 

serviceRoles:
- name: datahub_gms_rl
  endpoints:
  - datahub-gms
$$ 

MIN_INSTANCES=1
MAX_INSTANCES=1
EXTERNAL_ACCESS_INTEGRATIONS = (datahub_spcs_egress_access_integration);

DROP SERVICE datahub_gms_svc;

/*
SHOW ENDPOINTS IN SERVICE datahub_gms_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_gms_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_gms_svc', '0','datahub-gms');
SHOW SERVICES;
*/