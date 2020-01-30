import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;

import java.util.Iterator;
import java.util.List;
import java.util.Date;
import java.text.SimpleDateFormat;

class WaveSQLManager 
{
  Connection conn;

  private String dbPath;
  private String analyzedTableName;
  private String waveTableName;
  
  WaveSQLManager(String path)
  {
    dbPath = path;
    openConnection();
    createTables();
  }

  public void openConnection()
  {
    try
    {
      Class.forName("org.sqlite.JDBC");
      conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    }
    catch (ClassNotFoundException e)
    {
      System.out.println("Could not load JDBC driver");
      e.printStackTrace();
    }
    catch (SQLException e) 
    {
      System.out.println("Could not make database connection");
      e.printStackTrace();
    }
  }

  public void closeConnection()
  {
    try
    {
     conn.close();
    }
    catch (SQLException e) 
    {
      System.out.println("Could not make database connection");
      e.printStackTrace();
    }
  }
  
  void createTables()
  {
    Date date = new Date();
    String strDate = new SimpleDateFormat("yyyyMMddhhmmss").format(date);
    analyzedTableName = "analysis" + strDate;
    waveTableName = "wave" + strDate;
    try
    {
      Statement cs = conn.createStatement();
      cs.executeUpdate("CREATE TABLE " + waveTableName + "(`number` INTEGER, `freq_min` REAL, `freq_max` REAL, `freq_ave` REAL, `level` REAL)" );
      cs.executeUpdate("CREATE TABLE " + analyzedTableName + "(`number` INTEGER, `amp` REAL, `zero_crossings` REAL, `freq_by_zero_crossings` REAL, `spelling_by_zero_crossings` TEXT, `freq_by_fft` REAL, `spelling_by_fft` TEXT)");
    }
    catch (SQLException e) 
    {
      System.out.println("Could not make database connection");
      e.printStackTrace();
    }
  }
  
  public void setRecord(List<Wave> waveDataList, Analysis analysisData)
  {
    try
    {
      PreparedStatement pstmt = conn.prepareStatement("INSERT INTO " + waveTableName + "(number, freq_min, freq_max, freq_ave, level) values(?, ?, ?, ?, ?);");
      for(Iterator<Wave> it = waveDataList.iterator(); it.hasNext();) {
        Wave waveData = it.next();
        pstmt.setInt(1, waveData.number);
        pstmt.setFloat(2, waveData.freq_min);
        pstmt.setFloat(3, waveData.freq_max);
        pstmt.setFloat(4, waveData.freq_ave);
        pstmt.setFloat(5, waveData.level);
        pstmt.addBatch();
      }
      pstmt.executeBatch();
      
      String analysisParams = 
        analysisData.number + ", " +
        analysisData.amp + ", " +
        analysisData.zeroCrossings + ", " +
        analysisData.freqByZeroCrossings + ", '" +
        analysisData.spellingByZeroCrossings + "', " +
        analysisData.freqByFft + ", '" +
        analysisData.spellingByFft + "'";      
      Statement cs = conn.createStatement();
      cs.executeUpdate("INSERT INTO " + analyzedTableName + "(number, amp, zero_crossings, freq_by_zero_crossings, spelling_by_zero_crossings, freq_by_fft, spelling_by_fft) values(" + analysisParams + ")");
    }
    catch (SQLException e) 
    {
      System.out.println("Could not make database connection");
      e.printStackTrace();
    }
  }
}
