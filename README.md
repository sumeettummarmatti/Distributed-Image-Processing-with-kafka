# Distributed Image Processing with Apache Kafka

A scalable and fault-tolerant system for parallel image processing using Apache Kafka, FastAPI, and multiple worker nodes.

---

## 📌 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Master Node Configuration](#master-node-configuration)
  - [Worker Node Configuration](#worker-node-configuration)
- [Running the System](#running-the-system)
  - [Start Kafka](#1-start-kafka)
  - [Start Master Node](#2-start-master-node)
  - [Start Worker Nodes](#3-start-worker-nodes)
- [Usage](#usage)
  - [Web Interface](#web-interface)
  - [API Interface](#api-interface)
- [Image Transformations](#image-transformations)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Performance](#performance)
- [API Documentation](#api-documentation)
- [License](#license)

---

## Overview

This project provides a distributed image processing pipeline using Apache Kafka. Images are:

- Uploaded to the Master Node
- Split into 512×512 tiles
- Sent to Kafka as tasks
- Processed by Worker Nodes in parallel
- Reconstructed back into the final image by the Master Node

---

## Features

- Distributed image processing using multiple workers  
- Kafka-backed message delivery (tasks/results/heartbeats)  
- Automatic load balancing across workers  
- Fault-tolerant — workers can fail and rejoin  
- Real-time progress tracking via Web UI  
- 6 built-in image transformations  
- REST API and WebSockets for updates  

---

## Technology Stack

| Component       | Technology            |
|----------------|------------------------|
| Language       | Python 3.8+            |
| Web Framework  | FastAPI                |
| Message Broker | Apache Kafka           |
| Image Processing | OpenCV, Pillow, NumPy |
| Database       | SQLite                 |
| Realtime       | WebSockets             |

---

## Prerequisites

- Python 3.8 or higher  
- Java 11 (for Kafka)  
- At least 4GB RAM per node  
- Local network or ZeroTier VPN if using multiple machines  

---

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/distributed-image-processing-kafka.git
cd distributed-image-processing-kafka

# Install dependencies
pip install -r requirements.txt
```

---

## 👥 Team Contributions

| Member        | Responsibilities |
|---------------|-------------------|
| **Person 1 (Node 1)** | Developed Master Node, Web UI, image tiling & reconstruction |
| **Person 2 (Node 2)** | Set up Kafka broker, topic management, Zookeeper & monitoring |
| **Person 3 (Node 3)** | Implemented Worker Node 1, image transformations & API handling |
| **Person 4 (Node 4)** | Implemented Worker Node 2, parallel processing & result publishing |

---

## 🏛 Architecture Details



### 🌀 Data Flow
1. Client uploads an image to the Master Node via web/API.  
2. Master validates the image and slices it into 512×512 tiles.  
3. Each tile is pushed to the **Kafka "tasks" topic"**.  
4. Worker nodes consume tiles from Kafka.  
5. Workers process tiles and send them back to **Kafka "results" topic**.  
6. Master listens to results, reconstructs the final image, and provides it for download.  
7. Workers continuously send **heartbeats** to Master via **"heartbeats" topic"**.

---

### ⚖ Load Balancing
- Kafka divides the `tasks` topic into **multiple partitions**.  
- Workers belong to a **consumer group (image-workers)**.  
- Kafka automatically assigns partitions → Worker 1 gets partition 0, Worker 2 gets partition 1, etc.  
- If one worker dies, Kafka reassigns partitions to healthy workers.

---

### 🛡 Fault Tolerance
| Mechanism        | Description |
|------------------|-------------|
| Kafka Persistence | Messages (tiles/results) are stored in Kafka logs to prevent loss. |
| Heartbeat System | Workers send heartbeats every few seconds — Master detects failure if missing. |
| Auto Rebalance   | When a worker dies, Kafka reassigns its tasks to other workers. |
| Master Tracking  | SQLite database stores tile progress to avoid duplicate processing. |

---

## 🔐 Security Considerations

For production deployments:
- ✅ Use **SASL authentication in Kafka**  
- ✅ Secure Master API with **API keys or OAuth**  
- ✅ Use **HTTPS/TLS** instead of plain HTTP  
- ✅ Validate and sanitize uploaded images  
- ✅ Deploy using **VPN or private network** (e.g., ZeroTier)  
- ✅ Add **rate limiting** to prevent abuse  

---

## 📄 License

This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute with proper attribution.
