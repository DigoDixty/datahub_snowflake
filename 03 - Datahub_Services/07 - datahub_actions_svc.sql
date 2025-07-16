USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_actions_svc
IN COMPUTE POOL DATAHUB_POOL
FROM SPECIFICATION $$
spec:
    containers:
    - name: datahub-actions
      image: /adm_snowflake/datahub/datahub_repository/acryldata/datahub-actions:head-slim
      env: 
        ACTIONS_CONFIG: ""
        ACTIONS_EXTRA_PACKAGES: ""
        DATAHUB_GMS_HOST: datahub-gms-svc.ejmu.svc.spcs.internal
        DATAHUB_GMS_PORT: 8080
        DATAHUB_GMS_PROTOCOL: http
        DATAHUB_SYSTEM_CLIENT_ID: __datahub_system
        DATAHUB_SYSTEM_CLIENT_SECRET: JohnSnowKnowsNothing
        KAFKA_BOOTSTRAP_SERVER: datahub-broker-svc.ejmu.svc.spcs.internal:29092
        KAFKA_PROPERTIES_SECURITY_PROTOCOL: PLAINTEXT
        METADATA_AUDIT_EVENT_NAME: MetadataAuditEvent_v4
        METADATA_CHANGE_LOG_VERSIONED_TOPIC_NAME: MetadataChangeLog_Versioned_v1
        SCHEMA_REGISTRY_URL: http://datahub-schema-registry-svc.ejmu.svc.spcs.internal:8081

        REQUESTS_CA_BUNDLE: /etc/ssl/certs/ca-certificates.crt
        SSL_CERT_FILE: /etc/ssl/certs/ca-certificates.crt
        PATH: /home/datahub/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        HOME: /home/datahub
        UV_INDEX_URL: https://pypi.python.org/simple
        VIRTUAL_ENV: /home/datahub/.venv

      command:
        - "/bin/bash"
        - "-c"
        - "/start_datahub_actions.sh"
    $$ 
MIN_INSTANCES=1
MAX_INSTANCES=1
EXTERNAL_ACCESS_INTEGRATIONS = (datahub_spcs_egress_access_integration);

/*
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_actions_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_actions_svc', '0','datahub-actions');
SHOW SERVICES;
ALTER SERVICE datahub_actions_svc SUSPEND;
ALTER SERVICE datahub_actions_svc RESUME;
GRANT SERVICE ROLE DATAHUB_FRONTENDREACT_SVC!DATAHUB_FRONTEND_REACT_RL TO ROLE DATAHUB_ROLE;
GRANT SERVICE ROLE DATAHUB_GMS_SVC!DATAHUB_GMS_RL TO ROLE DATAHUB_ROLE;
*/

GRANT SERVICE ROLE DATAHUB_FRONTENDREACT_SVC!DATAHUB_FRONTEND_REACT_RL TO ROLE DATAHUB_ROLE;
GRANT SERVICE ROLE DATAHUB_GMS_SVC!DATAHUB_GMS_RL TO ROLE DATAHUB_ROLE;
