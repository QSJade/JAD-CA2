package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    public static Connection getConnection() {
        String dbClass = "org.postgresql.Driver";
        Connection connection = null;

        try {
        	Class.forName(dbClass);
        } catch (ClassNotFoundException e) {

            e.printStackTrace();
        }
        try {
        	connection = DriverManager.getConnection("jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require");
        }catch (SQLException e) {

                e.printStackTrace();
            }
            return connection;
    }
}
