USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE SERVICE datahub_elasticsearch_svc
  IN COMPUTE POOL DATAHUB_POOL
  FROM SPECIFICATION $$
    spec:
      containers:
      - name: elasticsearch
        image: /adm_snowflake/datahub/datahub_repository/elasticsearch:7.10.1
        env:
            SERVER_PORT: 9200
            DATAHUB_MAPPED_ELASTIC_PORT: 9200
            discovery.type: single-node
            xpack.security.enabled: false
            ES_JAVA_OPTS: -Xms256m -Xmx512m -Dlog4j2.formatMsgNoLookups=true
            OPENSEARCH_JAVA_OPTS: -Xms512m -Xmx512m -Dlog4j2.formatMsgNoLookups=true

        volumeMounts:
          - name: block-elasticsearch
            mountPath: /usr/share/elasticsearch/data

      volumes:
      - name: block-elasticsearch
        source: block
        size: 1000Gi

      endpoints:
      - name: elasticsearch
        port: 9200
        public: true

      $$
      
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

CREATE OR REPLACE SNAPSHOT snapshot_elasticsearch_data
FROM SERVICE datahub_elasticsearch_svc
VOLUME "block-elasticsearch"
INSTANCE 0
COMMENT='data volume to elasticsearch';

/*
ALTER SERVICE datahub_elasticsearch_svc SUSPEND;
ALTER SERVICE datahub_elasticsearch_svc RESUME;
SHOW ENDPOINTS IN SERVICE datahub_elasticsearch_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_elasticsearch_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_elasticsearch_svc', '0','elasticsearch');
SHOW SERVICES;

DROP SERVICE datahub_elasticsearch_svc FORCE;
*/