<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="at.favre.lib.crypto.bcrypt.BCrypt" %>

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect("login.jsp?errCode=notLoggedIn");
    return;
}

final String PEPPER = "MySuperSecretPepper123!";

String username = request.getParameter("username");
String password = request.getParameter("password");
String address  = request.getParameter("address");  

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String sql;
    PreparedStatement ps;

    // If password is provided, update name + address + password
    if (password != null && !password.isEmpty()) {
        String bcryptHash = BCrypt.withDefaults().hashToString(12, (password + PEPPER).toCharArray());

        sql = "UPDATE customers SET name = ?, address = ?, password = ? WHERE customer_id = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ps.setString(2, address);
        ps.setString(3, bcryptHash);
        ps.setInt(4, customerId);

    } else {
        // No password
        sql = "UPDATE customers SET name = ?, address = ? WHERE customer_id = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ps.setString(2, address);
        ps.setInt(3, customerId);
    }

    int rows = ps.executeUpdate();
    if (rows > 0) {
%>
        <script>
            alert('Account updated successfully!');
            window.location.href = '../profile.jsp';
        </script>
<%
    } else {
        response.sendRedirect("../profile.jsp?errCode=updateFail");
    }

    ps.close();
    conn.close();

} catch (Exception e) {
    out.println("Error: " + e);
}
%>
