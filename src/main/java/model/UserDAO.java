package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import at.favre.lib.crypto.bcrypt.BCrypt;
import config.DBConnection;

public class UserDAO {

    private static final String PEPPER = "MySuperSecretPepper123!";

    // ================= LOGIN (VERIFY PASSWORD) =================
    public User validateLogin(String email, String password) throws SQLException {

        User uBean = null;
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT * FROM customers WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");

                if (storedHash != null && !storedHash.isEmpty()) {

                    BCrypt.Result result = BCrypt.verifyer()
                            .verify((password + PEPPER).toCharArray(), storedHash);

                    if (result.verified) {
                        uBean = new User();
                        uBean.setCustomerId(rs.getInt("customer_id"));
                        uBean.setName(rs.getString("name"));
                        uBean.setEmail(rs.getString("email"));
                        uBean.setAddress(rs.getString("address"));
                        uBean.setRole(rs.getString("role"));
                    }
                }
            }

        } catch (Exception e) {
            System.out.println("Login Error: " + e);
        } finally {
            if (conn != null) conn.close();
        }

        return uBean; // null if invalid login
    }

    // ================= GET USER BY EMAIL =================
    public User getUserDetails(String email) throws SQLException {

        User uBean = null;
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            String sqlStr = "SELECT * FROM customers WHERE email = ?";
            PreparedStatement pstmt = conn.prepareStatement(sqlStr);
            pstmt.setString(1, email);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                uBean = new User();
                uBean.setCustomerId(rs.getInt("customer_id"));
                uBean.setName(rs.getString("name"));
                uBean.setEmail(rs.getString("email"));
                uBean.setAddress(rs.getString("address"));
                uBean.setPassword(rs.getString("password"));
                uBean.setRole(rs.getString("role"));
            }

        } catch (Exception e) {
            System.out.print("UserDetailsDB Error: " + e);
        } finally {
            if (conn != null) conn.close();
        }

        return uBean;
    }

    // ================= INSERT USER (REGISTER) =================
    public int insertUser(String name, String email, String address, String hashedPassword, String role)
            throws SQLException {

        Connection conn = null;
        int nrow = 0;

        try {
            conn = DBConnection.getConnection();

            String sqlStr =
                "INSERT INTO customers (name, email, address, password, role) VALUES (?, ?, ?, ?, ?)";

            PreparedStatement pstmt = conn.prepareStatement(sqlStr);
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, address);
            pstmt.setString(4, hashedPassword);
            pstmt.setString(5, role);

            nrow = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }

        return nrow;
    }
}
