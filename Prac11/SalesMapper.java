import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import java.io.IOException;

public class SalesMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    
    private Text country = new Text();
    private IntWritable sales = new IntWritable();
    
    @Override
    public void map(LongWritable key, Text value, Context context) 
            throws IOException, InterruptedException {
        
        String line = value.toString();
        
        if (line.contains("timestamp")) {
            return;
        }
        
        try {
            String[] fields = line.split(",");
            
            if (fields.length >= 5) {
                String countryStr = fields[2].trim();
                int salesAmount = Integer.parseInt(fields[4].trim());
                
                country.set(countryStr);
                sales.set(salesAmount);
                context.write(country, sales);
            }
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
