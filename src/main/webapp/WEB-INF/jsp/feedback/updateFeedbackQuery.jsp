<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>

<%
String feedbackIdStr = request.getParameter("feedbackId");
String serviceIdStr = request.getParameter("serviceId");

// Check login
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}

// Validate feedback ID
if (feedbackIdStr == null || feedbackIdStr.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/feedback/update?feedbackId=" + feedbackIdStr + "&serviceId=" + serviceIdStr + "&errCode=missingId");
    return;
}
int feedbackId = Integer.parseInt(feedbackIdStr);

// Validate rating safely
String ratingStr = request.getParameter("rating");
int rating = 0;
try {
    rating = Integer.parseInt(ratingStr);
} catch (Exception ex) {
    response.sendRedirect(request.getContextPath() + "/feedback/update?feedbackId=" + feedbackId + "&serviceId=" + serviceIdStr + "&errCode=ratingFail");
    return;
}

if (rating < 1 || rating > 5) {
    response.sendRedirect(request.getContextPath() + "/feedback/update?feedbackId=" + feedbackId + "&serviceId=" + serviceIdStr + "&errCode=ratingFail");
    return;
}

// Validate comments
String comments = request.getParameter("comments");
if (comments == null || comments.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/feedback/update?feedbackId=" + feedbackId + "&serviceId=" + serviceIdStr + "&errCode=commentEmpty");
    return;
}

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String sql = "CALL update_feedback(?,?,?,?)";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, feedbackId);
    ps.setInt(2, customerId);
    ps.setInt(3, rating);
    ps.setString(4, comments);

    try {
        ps.execute();
        conn.close();
%>
        <script>
            alert('Feedback updated successfully!');
            window.location.href = '<%= request.getContextPath() %>/serviceDetails?serviceId=<%= serviceIdStr %>';
        </script>
<%
    } catch (SQLException procErr) {
        conn.close();
        response.sendRedirect(request.getContextPath() + "/feedback/update?feedbackId=" + feedbackId + "&serviceId=" + serviceIdStr + "&errCode=updateFail");
    }
} catch (Exception e) {
    out.println("Error: " + e);
}
%>