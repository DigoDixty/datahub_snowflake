USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_upgrade_svc
IN COMPUTE POOL DATAHUB_POOL
FROM SPECIFICATION $$
spec:
    containers:
    - name: datahubupgrade
      image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-upgrade:head
      args: [
          -u,
          SystemUpdate
          ]
      env: 
          EBEAN_DATASOURCE_USERNAME: datahub
          EBEAN_DATASOURCE_PASSWORD: datahub
          EBEAN_DATASOURCE_HOST: datahub-mysql-svc.ejmu.svc.spcs.internal:3306
          EBEAN_DATASOURCE_URL: jdbc:mysql://datahub-mysql-svc.ejmu.svc.spcs.internal:3306/datahub?verifyServerCertificate=false&useSSL=true&useUnicode=yes&characterEncoding=UTF-8
          EBEAN_DATASOURCE_DRIVER: com.mysql.jdbc.Driver
          
          KAFKA_BOOTSTRAP_SERVER: datahub-broker-svc.ejmu.svc.spcs.internal:29092
          KAFKA_SCHEMAREGISTRY_URL: http://datahub-schema-registry-svc.ejmu.svc.spcs.internal:8081
          
          ELASTICSEARCH_HOST: datahub-elasticsearch-svc.ejmu.svc.spcs.internal
          ELASTICSEARCH_PORT: 9200
          ELASTICSEARCH_INDEX_BUILDER_MAPPINGS_REINDEX: true
          ELASTICSEARCH_INDEX_BUILDER_SETTINGS_REINDEX: true
          ELASTICSEARCH_BUILD_INDICES_CLONE_INDICES: false
          GRAPH_SERVICE_IMPL: elasticsearch
    
          DATAHUB_GMS_HOST: datahub-gms-svc.ejmu.svc.spcs.internal
          DATAHUB_GMS_PORT: 8080
          ENTITY_REGISTRY_CONFIG_PATH: /datahub/datahub-gms/resources/entity-registry.yml
          
          BACKFILL_BROWSE_PATHS_V2: true
          REPROCESS_DEFAULT_BROWSE_PATHS_V2: false
$$
MIN_INSTANCES=1
MAX_INSTANCES=1;

DROP SERVICE datahub_upgrade_svc;

/*
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_upgrade_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_upgrade_svc', '0','datahubupgrade');
DROP SERVICE datahub_upgrade_svc;
SHOW SERVICES;
*/