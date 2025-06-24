USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE STAGE IF NOT EXISTS ADM_SNOWFLAKE.DATAHUB.VOL_CONTAINER DIRECTORY = ( ENABLE = true ) ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );

CREATE SERVICE datahub_frontendreact_svc
IN COMPUTE POOL DATAHUB_POOL
FROM SPECIFICATION $$
spec:
    containers:
    - name: datahub-frontend-react
      image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-frontend-react:head
      env:
        DATAHUB_GMS_HOST: datahub-gms-svc.ejmu.svc.spcs.internal
        DATAHUB_GMS_PORT: 8080
        DATAHUB_SECRET: YouKnowNothing
        DATAHUB_APP_VERSION: 1.0
        DATAHUB_PLAY_MEM_BUFFER_SIZE: 10MB
        JAVA_OPTS: -Xms512m -Xmx512m -Dhttp.port=9002 -Dconfig.file=datahub-frontend/conf/application.conf -Djava.security.auth.login.config=datahub-frontend/conf/jaas.conf -Dlogback.configurationFile=datahub-frontend/conf/logback.xml -Dlogback.debug=false -Dpidfile.path=/dev/null

        KAFKA_BOOTSTRAP_SERVER: datahub-broker-svc.ejmu.svc.spcs.internal:29092
        DATAHUB_TRACKING_TOPIC: DataHubUsageEvent_v1

        ELASTIC_CLIENT_HOST: datahub-elasticsearch-svc.ejmu.svc.spcs.internal
        ELASTIC_CLIENT_PORT: 9200

      volumeMounts:
        - name: frontend
          mountPath: ${HOME}/.datahub/plugins:/etc/datahub/plugins

    volumes:
    - name: frontend
      source: "@adm_snowflake.datahub.vol_container/frontend/plugins"

    endpoints:
    - name: datahub-frontend-react
      port: 9002
      public: true
      
serviceRoles:
- name: datahub_frontend_react_rl
  endpoints:
  - datahub-frontend-react    
$$

MIN_INSTANCES=1
MAX_INSTANCES=1
EXTERNAL_ACCESS_INTEGRATIONS = (datahub_spcs_egress_access_integration);
   
/*
SHOW ENDPOINTS IN SERVICE datahub_frontendreact_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_frontendreact_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_frontendreact_svc', '0','datahub-frontend-react');
SHOW SERVICES;
*/
