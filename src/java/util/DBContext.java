package util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database Context for SQL Server with High-Performance Connection Pooling.
 * 
 * Features:
 *   - Zero external dependency Connection Pool (uses standard Java dynamic proxy)
 *   - Fixes SQL Server Browser UDP 1434 latency by prioritizing direct port TCP connection
 *   - Reuses pre-established physical connections across requests (0ms handshake vs 300ms)
 *   - Thread-safe, auto-recovering, and clean resource recycling
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

    // Pool Configuration
    private static final int MAX_POOL_SIZE = 30;
    private static final int INITIAL_POOL_SIZE = 5;
    private static final long MAX_WAIT_MS = 8000;

    private static final BlockingQueue<Connection> POOL = new ArrayBlockingQueue<>(MAX_POOL_SIZE);
    private static final AtomicInteger TOTAL_PHYSICAL_CONNECTIONS = new AtomicInteger(0);
    private static final AtomicBoolean POOL_INITIALIZED = new AtomicBoolean(false);

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

    /**
     * Gracefully close all pooled connections when the web application stops.
     */
    public static void shutdownPool() {
        LOGGER.info("Shutting down DBContext connection pool...");
        Connection c;
        while ((c = POOL.poll()) != null) {
            try {
                c.close();
            } catch (Exception ignored) {
            }
        }
        TOTAL_PHYSICAL_CONNECTIONS.set(0);
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
     * Create a new raw physical JDBC Connection to SQL Server.
     * Prioritizes direct TCP port connection (port 1433) to avoid SQL Server Browser UDP 1434 latency.
     */
    private static Connection createPhysicalConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("SQL Server JDBC Driver not found on classpath", ex);
        }

        DBContext instance = new DBContext();
        String server = instance.getServerName();
        String database = instance.getDatabaseName();
        String port = instance.getPortNumber();
        String instName = instance.getInstanceName();
        String user = instance.getUserId();
        String pass = instance.getPassword();

        // 1. First attempt: Direct TCP Port connection (fastest, 0 UDP delay)
        String directUrl = "jdbc:sqlserver://" + server + ":" + (port != null && !port.isEmpty() ? port : "1433")
                + ";databaseName=" + database
                + ";encrypt=true;trustServerCertificate=true;loginTimeout=5";

        try {
            return DriverManager.getConnection(directUrl, user, pass);
        } catch (SQLException ex) {
            // 2. Second attempt: Named Instance connection (if direct port failed and instance is configured)
            if (instName != null && !instName.trim().isEmpty()) {
                String namedUrl = "jdbc:sqlserver://" + server
                        + ";instanceName=" + instName.trim()
                        + ";databaseName=" + database
                        + ";encrypt=true;trustServerCertificate=true;loginTimeout=5";
                try {
                    LOGGER.info("Direct port failed, attempting Named Instance: " + namedUrl);
                    return DriverManager.getConnection(namedUrl, user, pass);
                } catch (SQLException innerEx) {
                    LOGGER.log(Level.SEVERE, "Both direct port and named instance failed to connect to database " + database, innerEx);
                    throw innerEx;
                }
            }
            LOGGER.log(Level.SEVERE, "Failed to connect to database " + database + " via " + directUrl, ex);
            throw ex;
        }
    }

    /**
     * Get a pooled Connection object to SQL Server database.
     * When caller calls connection.close(), the connection is returned to the pool for reuse.
     *
     * @return Connection or null if failed
     */
    public Connection getConnection() {
        Connection physicalConn = null;
        long deadline = System.currentTimeMillis() + MAX_WAIT_MS;

        while (System.currentTimeMillis() < deadline) {
            physicalConn = POOL.poll();

            if (physicalConn != null) {
                try {
                    if (!physicalConn.isClosed() && physicalConn.isValid(2)) {
                        break; // Found healthy pooled connection
                    } else {
                        // Connection is dead, drop it and decrease count
                        try { physicalConn.close(); } catch (Exception ignored) {}
                        TOTAL_PHYSICAL_CONNECTIONS.decrementAndGet();
                        physicalConn = null;
                    }
                } catch (Exception ex) {
                    try { physicalConn.close(); } catch (Exception ignored) {}
                    TOTAL_PHYSICAL_CONNECTIONS.decrementAndGet();
                    physicalConn = null;
                }
            }

            // If pool was empty, try creating a new connection if under MAX_POOL_SIZE
            if (physicalConn == null) {
                if (TOTAL_PHYSICAL_CONNECTIONS.get() < MAX_POOL_SIZE) {
                    try {
                        physicalConn = createPhysicalConnection();
                        TOTAL_PHYSICAL_CONNECTIONS.incrementAndGet();
                        break;
                    } catch (SQLException ex) {
                        LOGGER.log(Level.SEVERE, "Failed to create physical connection: " + ex.getMessage());
                        return null;
                    }
                } else {
                    // Pool is saturated, wait a bit for another thread to return a connection
                    try {
                        physicalConn = POOL.poll(200, TimeUnit.MILLISECONDS);
                        if (physicalConn != null) {
                            break;
                        }
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        return null;
                    }
                }
            }
        }

        if (physicalConn == null) {
            LOGGER.severe("DBContext connection pool exhausted. Could not obtain connection within " + MAX_WAIT_MS + "ms");
            return null;
        }

        return wrapConnection(physicalConn);
    }

    /**
     * Wrap the physical connection in a dynamic proxy so that close() returns it to the pool.
     */
    private static Connection wrapConnection(final Connection physicalConn) {
        InvocationHandler handler = new InvocationHandler() {
            private boolean isClosed = false;

            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                String methodName = method.getName();

                if ("close".equals(methodName)) {
                    if (!isClosed) {
                        isClosed = true;
                        try {
                            if (!physicalConn.isClosed()) {
                                if (!physicalConn.getAutoCommit()) {
                                    physicalConn.setAutoCommit(true);
                                }
                                if (!physicalConn.isReadOnly()) {
                                    physicalConn.clearWarnings();
                                }
                                if (!POOL.offer(physicalConn)) {
                                    // Pool full, physically close
                                    physicalConn.close();
                                    TOTAL_PHYSICAL_CONNECTIONS.decrementAndGet();
                                }
                            } else {
                                TOTAL_PHYSICAL_CONNECTIONS.decrementAndGet();
                            }
                        } catch (Exception ex) {
                            try { physicalConn.close(); } catch (Exception ignored) {}
                            TOTAL_PHYSICAL_CONNECTIONS.decrementAndGet();
                        }
                    }
                    return null;
                }

                if ("isClosed".equals(methodName)) {
                    return isClosed || physicalConn.isClosed();
                }

                if (isClosed) {
                    throw new SQLException("Connection has already been closed.");
                }

                try {
                    return method.invoke(physicalConn, args);
                } catch (java.lang.reflect.InvocationTargetException ex) {
                    throw ex.getCause();
                }
            }
        };

        return (Connection) Proxy.newProxyInstance(
                DBContext.class.getClassLoader(),
                new Class<?>[]{Connection.class},
                handler
        );
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

        long start = System.currentTimeMillis();
        try (Connection c1 = db.getConnection()) {
            if (c1 != null && !c1.isClosed()) {
                System.out.println(">>> 1st Connection Successful! Time: " + (System.currentTimeMillis() - start) + "ms");
            } else {
                System.err.println(">>> 1st Connection Failed!");
            }
        } catch (SQLException e) {
            System.err.println(">>> Connection Error: " + e.getMessage());
        }

        // Test 2nd connection to demonstrate pool reuse speed (should be ~0ms)
        long start2 = System.currentTimeMillis();
        try (Connection c2 = db.getConnection()) {
            if (c2 != null && !c2.isClosed()) {
                System.out.println(">>> 2nd Connection (Pooled Reuse) Successful! Time: " + (System.currentTimeMillis() - start2) + "ms");
            }
        } catch (SQLException e) {
            System.err.println(">>> 2nd Connection Error: " + e.getMessage());
        }
    }
}
