# Practical 11: Big Data Analytics I - MapReduce

## Table of Contents
1. [MapReduce Introduction](#mapreduce-introduction)
2. [Architecture and Concepts](#architecture-and-concepts)
3. [Hadoop Setup Instructions](#hadoop-setup-instructions)
4. [Assignment Overview](#assignment-overview)
5. [Java Implementation](#java-implementation)
6. [Viva Questions & Answers](#viva-questions--answers)

---

## MapReduce Introduction

### What is MapReduce?

**MapReduce** is a programming model and an associated implementation for processing and generating large data sets with a parallel, distributed algorithm on a cluster.

#### Key Characteristics:
- **Distributed Processing**: Processes large datasets across multiple nodes
- **Parallel Execution**: Breaks down large tasks into smaller sub-tasks
- **Fault Tolerance**: Handles node failures gracefully
- **Scalability**: Can scale from single machines to thousands of nodes

### When to Use MapReduce?

✓ **Good for:**
- Batch processing of large datasets
- ETL (Extract, Transform, Load) operations
- Log file analysis and data mining
- Simple aggregation operations

✗ **Not ideal for:**
- Real-time processing
- Complex iterative algorithms
- Interactive queries

---

## Architecture and Concepts

### MapReduce Workflow

```
INPUT DATA
    ↓
[MAP PHASE] - Process individual records
    ↓ (Emit key-value pairs)
[SHUFFLE & SORT] - Group values by key
    ↓
[REDUCE PHASE] - Aggregate values per key
    ↓
OUTPUT RESULTS
```

### Components

#### 1. **Mapper**
- Processes input data records individually
- Emits intermediate key-value pairs
- Functions independently on different data chunks

```
Input:  timestamp,ip,country,product,sales,status
Output: <country, sales>

Example:
  2024-04-01 10:15:23, 192.168.1.101, USA, Laptop, 1200, 200
  ↓
  <"USA", 1200>
```

#### 2. **Shuffle and Sort**
- Groups all values with the same key together
- Sorts the keys
- Acts as middleware between Map and Reduce phases

```
Mapper output:        Shuffle & Sort:
("USA", 1200)         ("Canada", [150, 150])
("India", 800)   →    ("Germany", [1200, 500])
("USA", 500)          ("India", [800, 1200, 400, 100])
("Canada", 150)       ("UK", [100, 1200])
...                   ("USA", [1200, 500, 400, 100])
```

#### 3. **Reducer**
- Receives grouped data from Shuffle & Sort
- Aggregates/processes all values for each key
- Produces final output

```
Input:   ("USA", [1200, 500, 400, 100])
Output:  ("USA", 2200)  [sum of all sales for USA]
```

---

## Hadoop Setup Instructions

### Prerequisites
- Java 7 or higher installed (Use SDKMAN if java not installed)
- Ubuntu/Linux environment (or WSL on Windows)
- SSH configured for password-less login

### Step-by-Step Installation

#### Step 1: Format the NameNode
```bash
cd hadoop-2.7.3
bin/hadoop namenode -format
```

#### Step 2: Start Hadoop Daemons

Navigate to the sbin directory:
```bash
cd hadoop-2.7.3/sbin
```

**Start NameNode** (Manages HDFS file system):
```bash
./hadoop-daemon.sh start namenode
```

**Start DataNode** (Stores actual data):
```bash
./hadoop-daemon.sh start datanode
```

**Start ResourceManager** (Manages cluster resources):
```bash
./yarn-daemon.sh start resourcemanager
```

**Start NodeManager** (Launches and monitors containers):
```bash
./yarn-daemon.sh start nodemanager
```

**Start JobHistoryServer** (Tracks completed jobs):
```bash
./mr-jobhistory-daemon.sh start historyserver
```

#### Step 3: Verify Services
```bash
jps
```

Expected output (processes running):
```
2341 NameNode
2456 DataNode
2567 ResourceManager
2678 NodeManager
2789 JobHistoryServer
```

#### Step 4: Create Working Directory
```bash
cd
sudo mkdir mapreduce_vijay
sudo chmod 777 -R mapreduce_vijay/
sudo chown -R vijay mapreduce_vijay/
```

#### Step 5: Copy Input Files
```bash
sudo cp /home/vijay/Desktop/logfiles1/* ~/mapreduce_vijay/
cd mapreduce_vijay/
ls
sudo chmod +r *.*
```

#### Step 6: Set CLASSPATH
```bash
export CLASSPATH="/home/vijay/hadoop-2.7.3/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.3.jar:/home/vijay/hadoop-2.7.3/share/hadoop/mapreduce/hadoop-mapreduce-client-common-2.7.3.jar:/home/vijay/hadoop-2.7.3/share/hadoop/common/hadoop-common-2.7.3.jar:~/mapreduce_vijay/SalesCountry/*:$HADOOP_HOME/lib/*"
```

#### Step 7: Compile Java Files
```bash
javac -d . SalesMapper.java SalesCountryReducer.java SalesCountryDriver.java
```

#### Step 8: Create Manifest File
```bash
gedit Manifest.txt
```

Add the following content:
```
Main-Class: SalesCountry.SalesCountryDriver
```

#### Step 9: Create JAR File
```bash
jar -cfm mapreduce_vijay.jar Manifest.txt SalesCountry/*.class
```

#### Step 10: Setup HDFS Input
```bash
sudo mkdir /input200
sudo cp access_log_short.csv /input200
$HADOOP_HOME/bin/hdfs dfs -put /input200 /
```

#### Step 11: Run MapReduce Job
```bash
$HADOOP_HOME/bin/hadoop jar mapreduce_vijay.jar /input200 /output200
```

#### Step 12: View Results
```bash
hadoop fs -ls /output200
hadoop fs -cat /output200/part-00000
```

#### Step 13: Monitor via Web Interface
Open browser and navigate to:
```
http://localhost:50070/dfshealth.html
```

---

## Assignment Overview

### Objective
Design a distributed application using MapReduce which processes a log file of a system to aggregate sales data by country.

### Input Data Format
```
timestamp,ip_address,country,product,sales,status_code
2024-04-01 10:15:23,192.168.1.101,USA,Laptop,1200,200
2024-04-01 10:16:45,192.168.1.102,India,Phone,800,200
...
```

### Expected Output
```
Canada  300
Germany 1700
India   2500
UK      1300
USA     2200
```

### Files Required

| File | Purpose |
|------|---------|
| `access_log_short.csv` | Input log file |
| `SalesMapper.java` | Extract country & sales |
| `SalesCountryReducer.java` | Aggregate by country |
| `SalesCountryDriver.java` | Configure & run job |
| `Manifest.txt` | JAR file configuration |

---

## Java Implementation

### SalesMapper.java

The Mapper reads each line of the CSV file and extracts the country and sales amount.

**Key Methods:**
- `map(LongWritable key, Text value, Context context)`: Processes each line

**Process:**
1. Read CSV line
2. Skip header line
3. Split by comma
4. Extract country (index 2) and sales (index 4)
5. Emit `<country, sales>` pair

### SalesCountryReducer.java

The Reducer receives all sales values for each country and sums them.

**Key Methods:**
- `reduce(Text key, Iterable<IntWritable> values, Context context)`: Aggregates values

**Process:**
1. Receive country as key
2. Receive all sales amounts for that country
3. Sum all values
4. Emit `<country, total_sales>` pair

### SalesCountryDriver.java

The Driver configures the MapReduce job with proper classes and paths.

**Key Configurations:**
- Sets Mapper class: `SalesMapper`
- Sets Reducer class: `SalesCountryReducer`
- Sets output types: `<Text, IntWritable>`
- Sets input/output paths from command line arguments

---

## Viva Questions & Answers

### Q1: Write down the steps for designing a distributed application using MapReduce which processes a log file

**Answer:**

**Step 1: Understand the Problem**
- Identify input data format (CSV log file)
- Define what needs to be extracted (country, sales)
- Determine desired output (total sales per country)

**Step 2: Design Mapper**
- Read each line from the input file
- Parse and extract relevant fields
- Emit intermediate key-value pairs
- Example: `<country, sales_amount>`

**Step 3: Design Reducer**
- Receive grouped intermediate results
- Aggregate values for each key
- Produce final output
- Example: `<country, total_sales>`

**Step 4: Create Driver Class**
- Configure Job object
- Set Mapper and Reducer classes
- Define input/output paths
- Submit the job to the cluster

**Step 5: Compile and Package**
```bash
javac -d . *.java
jar -cfm application.jar Manifest.txt *.class
```

**Step 6: Upload Input Data to HDFS**
```bash
hadoop fs -put input_file /input_path
```

**Step 7: Execute MapReduce Job**
```bash
hadoop jar application.jar /input_path /output_path
```

**Step 8: Retrieve and Analyze Results**
```bash
hadoop fs -cat /output_path/part-00000
```

---

### Q2: Explain MapReduce Phases

**Answer:**

**1. Input Phase**
- Data is split into chunks (HDFS blocks)
- Each split is assigned to a Mapper task

**2. Map Phase**
- Mapper processes each input split
- Emits intermediate <key, value> pairs
- One mapper operates on one split independently

**3. Shuffle Phase**
- Framework groups all values by key
- Sorts keys alphabetically
- Is transparent to programmer

**4. Reduce Phase**
- Reducer receives <key, all_values> for each unique key
- Aggregates/processes values
- Emits final <key, result> pairs

**5. Output Phase**
- Results are written to HDFS
- Multiple output files if multiple reducers

---

### Q3: What is the role of Hadoop NameNode and DataNode?

**Answer:**

**NameNode (Master):**
- Manages the file system namespace
- Maintains the file system tree
- Tracks file locations (block inventory)
- Does NOT store actual data
- Is a single point of failure (mitigated with HA)

**DataNode (Slave):**
- Performs block creation, deletion, replication
- Stores the actual data blocks
- Sends heartbeats to NameNode (every 3 seconds)
- Sends block inventory to NameNode
- Can scale to thousands of nodes

---

### Q4: What is the Shuffle and Sort phase?

**Answer:**

The Shuffle and Sort phase is an intermediate phase between Map and Reduce:

1. **Shuffle**: Framework collects all mappers' output and groups by key
2. **Sort**: Keys are sorted in ascending order
3. **Partitioning**: Data is partitioned across reducers (based on key)
4. **Merging**: Values for the same key are merged together

Example:
```
Before Shuffle:     After Shuffle:
("USA", 1200)       ("Canada", [150, 200])
("India", 800)  →   ("India", [800, 1200, 500])
("USA", 500)        ("USA", [1200, 500, 300])
("Canada", 150)
...
```

---

### Q5: How does MapReduce handle failures?

**Answer:**

**Task Failures:**
- TaskTracker detects task failure via heartbeat loss
- Task is re-executed on another node
- Failed tasks don't affect overall job

**Node Failures:**
- NameNode doesn't receive heartbeat from DataNode
- Blocks on failed node are re-replicated
- Data redundancy (default 3 replicas) ensures no data loss

**NameNode Failures:**
- Manual restart required (or use HA with Secondary NameNode)
- Job history is preserved in JobHistoryServer

**Job Failures:**
- If job fails, all results are discarded
- Job can be resubmitted and restarted

---

## Summary

| Concept | Role |
|---------|------|
| **Mapper** | Extract and emit key-value pairs |
| **Shuffle & Sort** | Group and sort intermediate data |
| **Reducer** | Aggregate values by key |
| **Driver** | Configure and submit job |
| **NameNode** | Manage HDFS metadata |
| **DataNode** | Store actual data blocks |
| **ResourceManager** | Manage cluster resources |

---

## References

- Apache Hadoop Official Documentation: https://hadoop.apache.org/
- MapReduce Tutorial: https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html
- HDFS Architecture: https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html
