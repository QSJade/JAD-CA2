package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import config.DBConnection;

public class ProfileDAO {

    // ================= GET USER BY CUSTOMER ID =================
    public User getUserDetails(int customerId) throws SQLException {

        User uBean = null;
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT * FROM customers WHERE customer_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);

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
            System.out.println("Error in getUserDetails(): " + e);
        } finally {
            if (conn != null) conn.close();
        }

        return uBean;
    }

    // ================= GET ALL USERS =================
    public List<User> getAllUsers() throws SQLException {

        List<User> userList = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT * FROM customers";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                User uBean = new User();
                uBean.setCustomerId(rs.getInt("customer_id"));
                uBean.setName(rs.getString("name"));
                uBean.setEmail(rs.getString("email"));
                uBean.setAddress(rs.getString("address"));
                uBean.setRole(rs.getString("role"));

                userList.add(uBean);
            }

        } catch (Exception e) {
            System.out.println("Error in getAllUsers(): " + e);
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }

        return userList;
    }

    // ================= INSERT USER =================
    public int insertUser(User user) throws SQLException {

        Connection conn = null;
        int nrow = 0;

        try {
            conn = DBConnection.getConnection();

            String sql =
                "INSERT INTO customers (name, email, password, role, address) " +
                "VALUES (?, ?, ?, ?, ?)";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getPassword());
            pstmt.setString(4, user.getRole());
            pstmt.setString(5, user.getAddress());

            nrow = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }

        return nrow;
    }

    // ================= UPDATE USER =================
    public int updateUser(int customerId, User user) throws SQLException {

        Connection conn = null;
        int nrow = 0;

        try {
            conn = DBConnection.getConnection();

            String sql =
                "UPDATE customers SET name = ?, email = ?, address = ?, role = ? " +
                "WHERE customer_id = ?";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getAddress());
            pstmt.setString(4, user.getRole());
            pstmt.setInt(5, customerId);

            nrow = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }

        return nrow;
    }

    // ================= DELETE USER =================
    public int deleteUser(int customerId) throws SQLException {

        Connection conn = null;
        int nrow = 0;

        try {
            conn = DBConnection.getConnection();

            String sql = "DELETE FROM customers WHERE customer_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);

            nrow = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }

        return nrow;
    }
}
