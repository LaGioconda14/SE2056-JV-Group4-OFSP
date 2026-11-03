package util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database Context for SQL Server connection.
 * Loads connection configuration from db.properties with secure fallback defaults.
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());
    private static final String PROPERTIES_FILE = "db.properties";

    private static final String DEFAULT_SERVER = "localhost";
    private static final String DEFAULT_DB = "OnlineFruitShop";
    private static final String DEFAULT_PORT = "1433";
    private static final String DEFAULT_INSTANCE = "SQLEXPRESS";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "sa";

    private static Properties props = null;

    static {
        loadProperties();
    }

    private static synchronized void loadProperties() {
        if (props != null) {
            return;
        }
        props = new Properties();

        // 1. Try loading via ClassLoaders
        InputStream is = null;
        try {
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            if (cl != null) {
                is = cl.getResourceAsStream(PROPERTIES_FILE);
            }
            if (is == null) {
                is = DBContext.class.getClassLoader().getResourceAsStream(PROPERTIES_FILE);
            }
            if (is == null) {
                is = DBContext.class.getResourceAsStream("/" + PROPERTIES_FILE);
            }

            // 2. Fallback to direct file paths (useful for CLI/testing)
            if (is == null) {
                String[] candidatePaths = {
                    "src/java/db.properties",
                    "db.properties",
                    "build/web/WEB-INF/classes/db.properties",
                    "../src/java/db.properties"
                };
                for (String path : candidatePaths) {
                    File f = new File(path);
                    if (f.exists() && f.isFile()) {
                        is = new FileInputStream(f);
                        break;
                    }
                }
            }

            if (is != null) {
                props.load(is);
                LOGGER.info("Successfully loaded database configuration from " + PROPERTIES_FILE);
            } else {
                LOGGER.warning("db.properties not found on classpath or filesystem. Using default connection settings.");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed to load " + PROPERTIES_FILE + ": " + ex.getMessage(), ex);
        } finally {
            if (is != null) {
                try {
                    is.close();
                } catch (Exception ignored) {
                }
            }
        }
    }

    private static String getProperty(String key, String fallbackKey, String defaultValue) {
        if (props == null) {
            return defaultValue;
        }
        String val = props.getProperty(key);
        if (val == null && fallbackKey != null) {
            val = props.getProperty(fallbackKey);
        }
        return (val != null && !val.trim().isEmpty()) ? val.trim() : defaultValue;
    }

    public String getServerName() {
        return getProperty("db.server", "serverName", DEFAULT_SERVER);
    }

    public String getDatabaseName() {
        return getProperty("db.database", "databaseName", DEFAULT_DB);
    }

    public String getPortNumber() {
        return getProperty("db.port", "portNumber", DEFAULT_PORT);
    }

    public String getInstanceName() {
        if (props != null) {
            String val = props.getProperty("db.instance");
            if (val == null) {
                val = props.getProperty("instanceName");
            }
            if (val != null) {
                return val.trim();
            }
        }
        return DEFAULT_INSTANCE;
    }

    public String getUserId() {
        String user = getProperty("db.username", "userId", null);
        if (user == null) {
            user = getProperty("db.user", "username", DEFAULT_USER);
        }
        return user;
    }

    public String getPassword() {
        return getProperty("db.password", "password", DEFAULT_PASSWORD);
    }

    /**
     * Get a Connection object to SQL Server database.
     *
     * @return Connection or null if failed
     */
    public Connection getConnection() {
        Connection conn = null;
        String server = getServerName();
        String database = getDatabaseName();
        String port = getPortNumber();
        String instance = getInstanceName();
        String user = getUserId();
        String pass = getPassword();

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Build URL based on instance or port
            String url;
            if (instance != null && !instance.trim().isEmpty()) {
                url = "jdbc:sqlserver://" + server + "\\" + instance + ":" + port
                        + ";databaseName=" + database
                        + ";encrypt=true;trustServerCertificate=true";
            } else {
                url = "jdbc:sqlserver://" + server + ":" + port
                        + ";databaseName=" + database
                        + ";encrypt=true;trustServerCertificate=true";
            }

            conn = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException ex) {
            LOGGER.log(Level.SEVERE, "SQL Server JDBC Driver not found. Please ensure mssql-jdbc jar is in WEB-INF/lib.", ex);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to connect to database " + database + " at " + server + ":" + port, ex);
        }
        return conn;
    }

    /**
     * Test connection directly from command line / IDE.
     */
    public static void main(String[] args) {
        DBContext db = new DBContext();
        System.out.println("Connecting with configuration:");
        System.out.println("  Server: " + db.getServerName());
        System.out.println("  Database: " + db.getDatabaseName());
        System.out.println("  Port: " + db.getPortNumber());
        System.out.println("  Instance: " + db.getInstanceName());
        System.out.println("  User: " + db.getUserId());
        try (Connection c = db.getConnection()) {
            if (c != null && !c.isClosed()) {
                System.out.println(">>> Database Connection Successful to: " + db.getDatabaseName());
            } else {
                System.err.println(">>> Connection Failed! Please check username, password, or SQL Server service.");
            }
        } catch (SQLException e) {
            System.err.println(">>> Connection Error: " + e.getMessage());
        }
    }
}
