USE ROLE DATAHUB_ROLE;
USE ADM_SNOWFLAKE;
USE SCHEMA DATAHUB;

CREATE OR REPLACE STAGE ADM_SNOWFLAKE.DATAHUB.BROKER 
DIRECTORY = ( ENABLE = true ) 
ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );

CREATE SERVICE datahub_broker_svc
IN COMPUTE POOL DATAHUB_POOL
FROM SPECIFICATION $$
spec:
    containers:
    - name: broker
      image: /adm_snowflake/datahub/datahub_repository/confluentinc/cp-kafka:7.4.0
      env:
          SERVER_PORT: 9092, 29092
          KAFKA_BROKER_ID: 1
          
          KAFKA_ZOOKEEPER_CONNECT: datahub-zookeeper-svc.ejmu.svc.spcs.internal:2181
          
          KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://datahub-broker-svc.ejmu.svc.spcs.internal:29092,PLAINTEXT_HOST://localhost:9092
          
          KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
          KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
          KAFKA_HEAP_OPTS: -Xms256m -Xmx256m
          KAFKA_CONFLUENT_SUPPORT_METRICS_ENABLE: false
          KAFKA_MESSAGE_MAX_BYTES: 5242880
          KAFKA_MAX_MESSAGE_BYTES: 5242880

      volumeMounts:
        - name: kafka
          mountPath: /var/lib/kafka/

    volumes:
    - name: kafka
      source: "@ADM_SNOWFLAKE.DATAHUB.BROKER"

    endpoints:
    - name: kafka-ext
      port: 9092
      public: true
    - name: kafka-int
      port: 29092
      public: true
$$

MIN_INSTANCES=1
MAX_INSTANCES=1;

/*
SHOW ENDPOINTS IN SERVICE datahub_broker_svc;
SELECT SYSTEM$GET_SERVICE_STATUS('datahub_broker_svc');
CALL SYSTEM$GET_SERVICE_LOGS('datahub_broker_svc', '0','broker');
SHOW SERVICES;
SHOW SERVICE CONTAINERS IN SERVICE DATAHUB_BROKER_SVC;
*/

ALTER SERVICE datahub_broker_svc SUSPEND;