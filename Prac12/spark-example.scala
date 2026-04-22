// Prac12: Big Data Analytics I - Scala Spark Example
// A simple example program using Apache Spark framework

import org.apache.spark.sql.SparkSession

object SparkExample {
  def main(args: Array[String]): Unit = {
    // Create a Spark session
    val spark = SparkSession.builder()
      .appName("BigDataAnalyticsI")
      .master("local[*]")
      .getOrCreate()

    // Suppress Spark INFO logs for cleaner output
    spark.sparkContext.setLogLevel("WARN")

    println("\n========================================")
    println("Big Data Analytics I - Spark Example")
    println("========================================\n")

    // Example 1: Create a simple DataFrame
    println("Example 1: Creating a simple DataFrame")
    val data = Seq(
      ("Alice", 25, "Engineering"),
      ("Bob", 30, "Finance"),
      ("Charlie", 28, "Marketing"),
      ("David", 35, "Engineering"),
      ("Eve", 27, "Finance")
    )

    val df = spark.createDataFrame(data).toDF("Name", "Age", "Department")
    println("DataFrame created with 5 rows:")
    df.show()

    // Example 2: Filter data
    println("\nExample 2: Filtering data (Age > 28)")
    df.filter(df("Age") > 28).show()

    // Example 3: Group by and aggregate
    println("\nExample 3: Grouping by Department and counting employees")
    df.groupBy("Department").count().show()

    // Example 4: Calculate average age by department
    println("\nExample 4: Average age by Department")
    df.groupBy("Department")
      .agg(Map("Age" -> "avg"))
      .show()

    // Example 5: RDD operations (lower-level API)
    println("\nExample 5: Using RDDs - Word count example")
    val words = spark.sparkContext.parallelize(
      Seq("Spark", "is", "great", "Spark", "is", "fast")
    )
    val wordCounts = words
      .map(word => (word, 1))
      .reduceByKey(_ + _)
      .collect()

    println("Word counts:")
    wordCounts.foreach { case (word, count) =>
      println(s"  $word: $count")
    }

    println("\n========================================")
    println("Example completed successfully!")
    println("========================================\n")

    // Stop the Spark session
    spark.stop()
  }
}
