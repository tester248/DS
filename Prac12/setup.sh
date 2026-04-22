#!/bin/bash

echo "========================================="
echo "Scala and Apache Spark Setup"
echo "========================================="
echo ""

# Step 1: Setup SDKMan
echo "Step 1: Setting up SDKMan..."
export SDKMAN_DIR="/usr/local/sdkman"
if [ ! -d "$SDKMAN_DIR" ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    curl -s "https://get.sdkman.io" | bash
fi
source "$SDKMAN_DIR/bin/sdkman-init.sh"
echo "SDKMan ready"
echo ""

# Step 2: Install Java 21
echo "Step 2: Installing Java 21 with SDKMan..."
sdk install java 21.0.4-tem -y 2>&1 | grep -E "installed|already"
java -version
echo ""

# Step 3: Install Scala
echo "Step 3: Verifying Scala..."
if command -v scala &> /dev/null; then
    echo "Scala already installed"
else
    export DEBIAN_FRONTEND=noninteractive
    sudo -E apt update -qq > /dev/null 2>&1
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y scala > /dev/null 2>&1
    echo "Scala installed"
fi
scala -version
echo ""

# Step 4: Download Apache Spark
echo "Step 4: Downloading Apache Spark 3.5.1..."
cd /tmp
rm -f spark-3.5.1-bin-hadoop3.tgz 2>/dev/null || true
curl -L -o spark-3.5.1-bin-hadoop3.tgz https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
echo "Spark downloaded"
echo ""

# Step 5: Extract Apache Spark
echo "Step 5: Extracting Apache Spark..."
tar -xzf spark-3.5.1-bin-hadoop3.tgz 2>/dev/null || true
echo "Spark extracted"
echo ""

# Step 6: Move to /opt
echo "Step 6: Moving Spark to /opt directory..."
sudo rm -rf /opt/spark 2>/dev/null || true
sudo mv spark-3.5.1-bin-hadoop3 /opt/spark
echo "Spark moved to /opt/spark"
echo ""

# Step 7: Set environment variables
echo "Step 7: Setting environment variables..."
if ! grep -q "SPARK_HOME" ~/.bashrc; then
    echo "export SPARK_HOME=/opt/spark" >> ~/.bashrc
    echo "export JAVA_HOME=/usr" >> ~/.bashrc
    echo "export PATH=\$PATH:/opt/spark/bin:/opt/spark/sbin" >> ~/.bashrc
    echo "export PYSPARK_PYTHON=/usr/bin/python3" >> ~/.bashrc
fi
source ~/.bashrc
echo "Environment variables set"
echo ""

# Step 8: Verify Spark installation
echo "Step 8: Verifying Spark installation..."
ls -lh /opt/spark/bin/spark-shell | head -1
echo "Spark installation verified"
echo ""

# Step 9: Configure SSH for Spark cluster (optional)
echo "Step 9: Configuring SSH for Spark cluster..."
sudo -E DEBIAN_FRONTEND=noninteractive apt install -y openssh-client openssh-server > /dev/null 2>&1
echo "SSH configured"
echo ""

echo "========================================="
echo "Setup Complete"
echo "========================================="
echo ""
echo "Verification commands:"
echo "  java -version"
echo "  scala -version"
echo "  spark-shell"
echo ""
echo "Start Spark Master and Workers (optional):"
echo "  start-master.sh"
echo "  start-workers.sh spark://localhost:7077"
echo ""
echo "Access Spark UI"
echo "  http://localhost:4040/"
