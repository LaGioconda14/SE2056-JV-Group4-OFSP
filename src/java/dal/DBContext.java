package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database Context for SQL Server connection.
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    // Connection parameters
    private final String serverName = "localhost";
    private final String databaseName = "OnlineFruitShop";
    private final String portNumber = "1433";
    private final String instanceName = ""; // Leave empty if default instance MSSQLSERVER
    private final String userId = "sa";
    private final String password = "your_password"; // CHANGE TO YOUR SQL SERVER SA PASSWORD

    /**
     * Get a Connection object to SQL Server database.
     *
     * @return Connection or null if failed
     */
    public Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // Build URL based on instance or port
            String url;
            if (instanceName != null && !instanceName.trim().isEmpty()) {
                url = "jdbc:sqlserver://" + serverName + "\\" + instanceName + ":" + portNumber 
                    + ";databaseName=" + databaseName 
                    + ";encrypt=true;trustServerCertificate=true";
            } else {
                url = "jdbc:sqlserver://" + serverName + ":" + portNumber 
                    + ";databaseName=" + databaseName 
                    + ";encrypt=true;trustServerCertificate=true";
            }

            conn = DriverManager.getConnection(url, userId, password);
        } catch (ClassNotFoundException ex) {
            LOGGER.log(Level.SEVERE, "SQL Server JDBC Driver not found. Please ensure mssql-jdbc jar is in WEB-INF/lib.", ex);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to connect to database " + databaseName + " at " + serverName + ":" + portNumber, ex);
        }
        return conn;
    }

    /**
     * Test connection directly from command line / IDE.
     */
    public static void main(String[] args) {
        DBContext db = new DBContext();
        try (Connection c = db.getConnection()) {
            if (c != null && !c.isClosed()) {
                System.out.println(">>> Database Connection Successful to: " + db.databaseName);
            } else {
                System.err.println(">>> Connection Failed! Please check username, password, or SQL Server service.");
            }
        } catch (SQLException e) {
            System.err.println(">>> Connection Error: " + e.getMessage());
        }
    }
}

