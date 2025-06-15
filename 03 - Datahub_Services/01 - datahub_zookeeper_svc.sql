USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_zookeeper_svc
  IN COMPUTE POOL DATAHUB_POOL
  FROM SPECIFICATION $$
    spec:
      containers:
      - name: zookeeper
        image: /adm_snowflake/datahub/datahub_repository/confluentinc/cp-zookeeper:7.4.0
        env:
          ZOOKEEPER_CLIENT_PORT: 2181
          ZOOKEEPER_TICK_TIME: 2000
        volumeMounts:
        - name: block-zkdata
          mountPath: /var/lib/zookeeper/data
        - name: block-zklogs
          mountPath: /var/lib/zookeeper/log

      volumes:
      - name: block-zkdata
        source: block
        size: 80Gi
      - name: block-zklogs
        source: block
        size: 80Gi

      endpoints:
      - name: zookeeper
        port: 2181
        public: true

      $$
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

CREATE OR REPLACE SNAPSHOT snapshot_zookeeper_data
FROM SERVICE datahub_zookeeper_svc
VOLUME "block-zkdata"
INSTANCE 0
COMMENT='data volume to zookeeper';

CREATE OR REPLACE SNAPSHOT snapshot_zookeeper_log
FROM SERVICE datahub_zookeeper_svc
VOLUME "block-zklogs"
INSTANCE 0
COMMENT='logs volume to zookeeper';

/*
ALTER SERVICE datahub_zookeeper_svc SUSPEND;
ALTER SERVICE datahub_zookeeper_svc RESUME;
SHOW ENDPOINTS IN SERVICE datahub_zookeeper_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_zookeeper_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_zookeeper_svc', '0','zookeeper');
SHOW SERVICES;

DROP SERVICE datahub_zookeeper_svc FORCE;
*/
