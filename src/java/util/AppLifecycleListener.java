package util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Standard ServletContextListener to manage application lifecycle in Tomcat/Jakarta EE.
 * Ensures clean resource disposal and zero thread/classloader leaks during hot-redeploy.
 */
@WebListener
public class AppLifecycleListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // App started cleanly
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Gracefully close all database connections when Tomcat stops or reloads the web app
        DBContext.shutdownPool();
    }
}
