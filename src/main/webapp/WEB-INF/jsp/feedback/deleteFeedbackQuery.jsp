<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>

<%
String feedbackIdStr = request.getParameter("feedbackId");
String serviceIdStr = request.getParameter("serviceId");

Integer customerId = (Integer) session.getAttribute("sessCustomerId");

// Validate login
if (customerId == null) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}

// Validate feedbackId
if (feedbackIdStr == null || feedbackIdStr.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/profile?errCode=deleteFail");
    return;
}

int feedbackId = Integer.parseInt(feedbackIdStr);

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String sql = "CALL delete_feedback(?,?)";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, feedbackId);
    ps.setInt(2, customerId);

    try {
        ps.execute();
        conn.close();
%>
        <script>
            alert('Feedback deleted successfully!');
            window.location.href = '<%= request.getContextPath() %>/serviceDetails?serviceId=<%= serviceIdStr %>';
        </script>
<%
    } catch(SQLException procErr) {
        conn.close();
        response.sendRedirect(request.getContextPath() + "/profile?errCode=deleteFail");
    }
} catch(Exception e) {
    out.println("SQL error: " + e.getMessage());
}
%>