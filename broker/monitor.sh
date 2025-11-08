#!/bin/bash

# ============================================================================
# KAFKA PIPELINE - MASTER MONITORING SCRIPT
#
# This single script handles all monitoring tasks for the Broker Admin.
# It can be run in different modes to provide a full status overview,
# monitor consumer groups, and tail log files.
#
# USAGE:
#   ./monitor.sh            - Shows the full status report (default).
#   ./monitor.sh logs         - Tails the Kafka server logs.
#   ./monitor.sh zklogs       - Tails the Zookeeper logs.
#   ./monitor.sh help         - Shows this help message.
#
# ============================================================================

# --- Configuration ---
BOOTSTRAP_SERVER="localhost:9092"
TOPICS=("tasks" "results" "heartbeats")
KAFKA_BIN_DIR="./bin" # Relative path to the bin directory

# --- Helper Functions for Color ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Functions for Different Monitoring Tasks ---

show_help() {
    echo "Kafka Pipeline - Master Monitoring Script"
    echo "------------------------------------------"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  (no command)    Shows the full status report (default)."
    echo "  logs            Continuously tails the Kafka server log."
    echo "  zklogs          Continuously tails the Zookeeper log."
    echo "  help            Displays this help message."
    echo ""
}

show_full_report() {
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN}  KAFKA PIPELINE - FULL STATUS REPORT${NC}"
    echo -e "${CYAN}====================================================${NC}"

    # SECTION 1: CORE SERVICE STATUS (monitor_broker.sh part 1)
    echo ""
    echo -e "${YELLOW}--- 1. Core Service Status ---${NC}"
    if pgrep -f "zookeeper" > /dev/null; then echo -e "${GREEN}✓ Zookeeper:   RUNNING${NC}"; else echo -e "${RED}✗ Zookeeper:   NOT RUNNING${NC}"; fi
    if pgrep -f "kafka.Kafka" > /dev/null; then echo -e "${GREEN}✓ Kafka Broker:  RUNNING${NC}"; else echo -e "${RED}✗ Kafka Broker:  NOT RUNNING${NC}"; fi

    # SECTION 2: TOPIC STATUS (monitor_broker.sh part 2)
    echo ""
    echo -e "${YELLOW}--- 2. Topic Configuration ---${NC}"
    "${KAFKA_BIN_DIR}/kafka-topics.sh" --bootstrap-server "$BOOTSTRAP_SERVER" --describe --topic tasks
    "${KAFKA_BIN_DIR}/kafka-topics.sh" --bootstrap-server "$BOOTSTRAP_SERVER" --describe --topic results
    "${KAFKA_BIN_DIR}/kafka-topics.sh" --bootstrap-server "$BOOTSTRAP_SERVER" --describe --topic heartbeats

    # SECTION 3: MESSAGE COUNTS (count_messages.sh)
    echo ""
    echo -e "${YELLOW}--- 3. Message Counts (Total Produced) ---${NC}"
    for topic in "${TOPICS[@]}"; do
        total_messages=$("${KAFKA_BIN_DIR}/kafka-run-class.sh" kafka.tools.GetOffsetShell --broker-list "$BOOTSTRAP_SERVER" --topic "$topic" --time -1 2>/dev/null | awk -F: '{sum+=$3} END {print sum}')
        printf "%-12s %s\n" "${topic}:" "${total_messages:-0}"
    done

    # SECTION 4: CONSUMER GROUP HEALTH (monitor_consumers.sh)
    echo ""
    echo -e "${YELLOW}--- 4. Consumer Group Status & Lag ---${NC}"
    CONSUMER_GROUPS=$("${KAFKA_BIN_DIR}/kafka-consumer-groups.sh" --bootstrap-server "$BOOTSTRAP_SERVER" --list 2>/dev/null)
    if [ -z "$CONSUMER_GROUPS" ]; then
        echo "No active consumer groups found yet."
    else
        for group in $CONSUMER_GROUPS; do
            echo "-> Describing group: '$group'"
            "${KAFKA_BIN_DIR}/kafka-consumer-groups.sh" --bootstrap-server "$BOOTSTRAP_SERVER" --describe --group "$group"
            echo ""
        done
    fi
    echo -e "${CYAN}================== End of Report ===================${NC}"
}

tail_kafka_logs() {
    echo -e "${YELLOW}--- Tailing Kafka Server Logs (logs/kafka.log) ---${NC}"
    echo "Press Ctrl+C to exit."
    echo "----------------------------------------------------"
    tail -f ./logs/kafka.log
}

tail_zookeeper_logs() {
    echo -e "${YELLOW}--- Tailing Zookeeper Logs (logs/zookeeper.log) ---${NC}"
    echo "Press Ctrl+C to exit."
    echo "----------------------------------------------------"
    tail -f ./logs/zookeeper.log
}

# --- Main Script Logic ---
# This part reads the first argument you pass to the script and decides which function to call.

case "$1" in
    logs)
        tail_kafka_logs
        ;;
    zklogs)
        tail_zookeeper_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        # If no argument is given, run the full report. This is the default.
        show_full_report
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'.${NC}"
        show_help
        exit 1
        ;;
esac
