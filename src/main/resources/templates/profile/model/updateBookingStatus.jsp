<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect("../../login.jsp?errCode=notLoggedIn");
    return;
}

// Get parameters
String action = request.getParameter("action"); // pay or cancel
String bookingIdStr = request.getParameter("bookingId");
if (bookingIdStr == null || action == null) {
    response.sendRedirect("../profile.jsp?errCode=invalidRequest");
    return;
}

int bookingId = Integer.parseInt(bookingIdStr);

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String updateSQL = null;
    if ("pay".equalsIgnoreCase(action)) {
        updateSQL = "UPDATE bookings SET status='confirmed' WHERE booking_id=? AND customer_id=?";
    } else if ("cancel".equalsIgnoreCase(action)) {
        updateSQL = "UPDATE bookings SET status='cancelled' WHERE booking_id=? AND customer_id=?";
    }

    if (updateSQL != null) {
        PreparedStatement ps = conn.prepareStatement(updateSQL);
        ps.setInt(1, bookingId);
        ps.setInt(2, customerId);
        ps.executeUpdate();
    }

    conn.close();
    response.sendRedirect("../profile.jsp");
} catch (Exception e) {
    out.println("Error: " + e);
}
%>

</body>
</html>