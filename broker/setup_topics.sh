#!/bin/bash
#
# Script to create the required Kafka topics for the Image Processing Pipeline.
# Run this script from the root of your Kafka installation directory.

KAFKA_BIN="./bin"
BOOTSTRAP_SERVER="localhost:9092"

echo "Creating 'tasks' topic with 2 partitions..."
$KAFKA_BIN/kafka-topics.sh --create \
    --topic tasks \
    --bootstrap-server $BOOTSTRAP_SERVER \
    --partitions 2 \
    --replication-factor 1

echo "Creating 'results' topic with 1 partition..."
$KAFKA_BIN/kafka-topics.sh --create \
    --topic results \
    --bootstrap-server $BOOTSTRAP_SERVER \
    --partitions 1 \
    --replication-factor 1

echo "Creating 'heartbeats' topic with 1 partition..."
$KAFKA_BIN/kafka-topics.sh --create \
    --topic heartbeats \
    --bootstrap-server $BOOTSTRAP_SERVER \
    --partitions 1 \
    --replication-factor 1

echo "Topic creation complete. Verifying topics..."
$KAFKA_BIN/kafka-topics.sh --list --bootstrap-server $BOOTSTRAP_SERVER