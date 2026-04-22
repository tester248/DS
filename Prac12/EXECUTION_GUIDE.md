# Prac12: Big Data Analytics I - Execution Guide

## Complete Command Sequence

### Phase 1: Environment Setup
```bash
cd /workspaces/DS/Prac12
bash setup.sh
source ~/.bashrc
```

### Phase 2: Verify Installation
```bash
java -version
scala -version
spark-shell --version
```

### Phase 3: View Your Scala Program
```bash
cat spark-example.scala
```

### Phase 4: Compile Scala Code
```bash
# Create target directory for compiled files
mkdir -p target

# Compile to bytecode
scalac -d target spark-example.scala
```

### Phase 5: Run with Spark
```bash
# Method 1: Using spark-submit (Recommended for Spark applications)
spark-submit --class SparkExample target/ spark-example.scala

# Method 2: Run compiled class with Spark
spark-submit --class SparkExample --master local[*] target/

# Method 3: Direct spark-shell execution
spark-shell < spark-example.scala
```

### Phase 6: Interactive Development (Optional)
```bash
# Launch Spark interactive shell
spark-shell

# Inside spark-shell, you can write Scala code interactively
# Type :quit to exit
```

### Phase 7: Cluster Operations (Optional)
```bash
# Start Spark Master service
start-master.sh

# Start Worker services
start-workers.sh spark://localhost:7077

# View Spark UI
# Open browser: http://localhost:8080/

# Stop services when done
stop-workers.sh
stop-master.sh
```

## Quick Start (Copy & Paste Everything)
```bash
cd /workspaces/DS/Prac12 && \
bash setup.sh && \
source ~/.bashrc && \
java -version && \
scala -version && \
mkdir -p target && \
scalac -d target spark-example.scala && \
echo "Compilation successful. Ready to run with Spark."
```

## Troubleshooting

**Issue: scalac command not found**
```bash
# Make sure Scala is in PATH
which scala
# If not found, verify installation
scala -version
```

**Issue: spark-submit not found**
```bash
# Make sure SPARK_HOME is set
echo $SPARK_HOME
# Should show: /opt/spark
```

**Issue: Java version mismatch**
```bash
# Verify Java 21 is being used
java -version
# Should show: openjdk version "21.x.x"
```

**Issue: Target directory error**
```bash
# Always create target directory first
mkdir -p target
scalac -d target spark-example.scala
```

## Key Directories
- Spark Installation: `/opt/spark`
- Your Project: `/workspaces/DS/Prac12`
- Compiled Classes: `/workspaces/DS/Prac12/target`
- Temporary Files: `/tmp`

## Environment Variables
```bash
# Verify these are set
echo "SPARK_HOME: $SPARK_HOME"
echo "JAVA_HOME: $JAVA_HOME"
echo "PATH contains: $(echo $PATH | grep spark)"
```
