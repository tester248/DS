#!/bin/bash

# Hadoop 3.5.0 Setup Script
# Basic commands for installation and MapReduce job execution

# Variables
HADOOP_HOME="/opt/hadoop-3.5.0"
WORK_DIR="$HOME/mapreduce"
INPUT_DIR="/input200"
OUTPUT_DIR="/output200"
HADOOP_VERSION="3.5.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Download Hadoop
echo "Step 1: Downloading Hadoop $HADOOP_VERSION..."
cd /tmp
wget -q https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
echo "Hadoop downloaded"
echo ""

# Step 2: Extract Hadoop
echo "Step 2: Extracting Hadoop..."
tar -xzf hadoop-$HADOOP_VERSION.tar.gz 2>/dev/null
sudo mv hadoop-$HADOOP_VERSION $HADOOP_HOME 2>/dev/null
echo "Hadoop extracted to $HADOOP_HOME"
echo ""

# Step 3: Set environment variables
echo "Step 3: Setting environment variables..."
export HADOOP_HOME=$HADOOP_HOME
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
mkdir -p $HADOOP_HOME/etc/hadoop
cat > $HADOOP_HOME/etc/hadoop/core-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
EOF
echo "Environment variables set"
echo ""

# Step 4: Format the NameNode
echo "Step 4: Formatting NameNode..."
cd $HADOOP_HOME
bin/hdfs namenode -format 2>&1 | grep -v "WARNING"
echo "NameNode formatted"
echo ""

# Step 5: Start Hadoop Daemons
echo "Step 5: Starting Hadoop Daemons..."
bin/hdfs --daemon start namenode 2>/dev/null
sleep 3
bin/hdfs --daemon start datanode 2>/dev/null
sleep 2
bin/yarn --daemon start resourcemanager 2>/dev/null
sleep 3
bin/yarn --daemon start nodemanager 2>/dev/null
sleep 2
bin/mapred --daemon start historyserver 2>/dev/null
sleep 3
echo "All daemons started"
sleep 5
echo ""

# Step 6: Verify services
echo "Step 6: Verifying running services..."
jps
echo ""

# Step 7: Create working directory
echo "Step 7: Setting up working directory..."
mkdir -p $WORK_DIR
cd $WORK_DIR
echo "Working directory created: $WORK_DIR"
echo ""

# Step 8: Copy input files
echo "Step 8: Copying input files..."
cp $SCRIPT_DIR/access_log_short.csv $WORK_DIR/
chmod +r $WORK_DIR/*
echo "Files copied to $WORK_DIR"
echo ""

# Step 9: Set CLASSPATH
echo "Step 9: Setting CLASSPATH..."
export CLASSPATH="$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/common/*:$WORK_DIR/SalesCountry/*:$HADOOP_HOME/lib/*"
echo "CLASSPATH configured"
echo ""

# Step 10: Compile Java files
echo "Step 10: Compiling Java files..."
cp $SCRIPT_DIR/Sales*.java $WORK_DIR/
cd $WORK_DIR
javac -d . SalesMapper.java SalesCountryReducer.java SalesCountryDriver.java 2>&1 | grep -v "warning"
echo "Java files compiled"
echo ""

# Step 11: Create Manifest file
echo "Step 11: Creating Manifest.txt..."
cat > Manifest.txt << EOF
Main-Class: SalesCountryDriver
EOF
echo "Manifest file created"
echo ""

# Step 12: Create JAR file
echo "Step 12: Creating JAR file..."
jar -cfm mapreduce.jar Manifest.txt *.class 2>/dev/null
ls -lh mapreduce.jar
echo "JAR file created"
echo ""

# Step 13: Create HDFS input directory and upload data
echo "Step 13: Setting up HDFS input..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p $INPUT_DIR 2>/dev/null
$HADOOP_HOME/bin/hdfs dfs -put access_log_short.csv $INPUT_DIR/ 2>/dev/null
$HADOOP_HOME/bin/hdfs dfs -ls $INPUT_DIR 2>/dev/null
echo "Input data uploaded to HDFS"
sleep 3
echo ""

# Step 14: Run MapReduce Job
echo "Step 14: Running MapReduce Job..."
$HADOOP_HOME/bin/hadoop jar mapreduce.jar $INPUT_DIR /output200 2>&1 | tail -20
echo "MapReduce job executed"
echo ""

# Step 15: View results
echo "Step 15: MapReduce Results..."
$HADOOP_HOME/bin/hadoop fs -ls /output200 2>/dev/null
echo ""
$HADOOP_HOME/bin/hadoop fs -cat /output200/part-r-00000 2>/dev/null
echo ""

# Step 16: Completion
echo "Step 16: MapReduce Execution Complete"
echo ""

echo "Hadoop Setup Complete"
echo ""
echo "Summary:"
echo "Hadoop Home: $HADOOP_HOME"
echo "Working Directory: $WORK_DIR"
echo "HDFS Input: $INPUT_DIR"
echo "HDFS Output: /output200"
echo "Application JAR: $WORK_DIR/mapreduce.jar"
