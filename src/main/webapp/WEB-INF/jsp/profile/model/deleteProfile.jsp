<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if(customerId == null){
    response.sendRedirect("login.jsp?errCode=notLoggedIn");
    return;
}

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    PreparedStatement ps = conn.prepareStatement("DELETE FROM customers WHERE customer_id=?");
    ps.setInt(1, customerId);

    int rows = ps.executeUpdate();
    if(rows > 0){
        session.invalidate(); // log out
        response.sendRedirect("../../homepage.jsp");
    } else {
        response.sendRedirect("../profile.jsp?errCode=deleteFail");
    }

    ps.close();
    conn.close();
} catch(Exception e){
    out.println("Error: " + e);
}
%>
