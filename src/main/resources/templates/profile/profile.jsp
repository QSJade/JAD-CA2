<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*" %>
<%@ include file="../header.jsp" %>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="../css/style.css">
<title>Profile</title>
</head>
<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}

// Check error messages
String errCode = request.getParameter("errCode");
if ("updateFail".equals(errCode)) {
    out.println("<p style='color: red;'>One of the values is incorrect. Please try again.</p>");
} else if ("deleteFail".equals(errCode)) {
    out.println("<p style='color: red;'>Something went wrong. Please try again.</p>");
}

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    // --- Load user info ---
    String username = "", email = "", address = "";
    PreparedStatement psUser = conn.prepareStatement("SELECT name, email, address FROM customers WHERE customer_id=?");
    psUser.setInt(1, customerId);
    ResultSet rsUser = psUser.executeQuery();
    if (rsUser.next()) {
        username = rsUser.getString("name");
        email = rsUser.getString("email");
        address = rsUser.getString("address");
    }
    rsUser.close();
    psUser.close();
%>

<h1>My Profile</h1>
<div class="form-wrapper">
    <form action="model/updateProfile.jsp" method="post" class="profile-form">
        <div class="form-row">
            <label for="username">Username:</label>
            <input type="text" name="username" id="username" value="<%= username %>">
        </div>
        <div class="form-row">
            <label for="email">Email:</label>
            <input type="email" name="email" id="email" value="<%= email %>" readonly>
        </div>
        <div class="form-row">
            <label for="address">Address:</label>
            <input type="text" name="address" id="address" value="<%= address %>">
        </div>
        <div class="form-row">
            <label for="password">Password:</label>
            <input type="password" name="password" id="password" placeholder="Edit to change">
        </div>
        <div class="button-row">
            <input type="submit" value="Update Profile" class="btn-update">
        </div>
    </form>

    <form action="model/deleteProfile.jsp" method="post" onsubmit="return confirm('Are you sure you want to delete your account?');" class="delete-form">
        <div class="button-row">
            <input type="submit" value="Delete Profile" class="btn-delete">
        </div>
    </form>
</div>

<%
    // --- Update past bookings & retrieve active bookings ---
    String sql = "WITH updated AS (" +
                 "  UPDATE bookings SET status='completed' " +
                 "  WHERE customer_id=? AND status='confirmed' AND end_date < CURRENT_DATE RETURNING *" +
                 ") " +
                 "SELECT b.booking_id, b.service_id, s.service_name, b.start_date, b.end_date, b.status, " +
                 "       CASE WHEN f.booking_id IS NOT NULL THEN TRUE ELSE FALSE END AS feedback_exists " +
                 "FROM bookings b " +
                 "JOIN services s ON b.service_id = s.service_id " +
                 "LEFT JOIN feedbacks f ON b.booking_id = f.booking_id " +
                 "WHERE b.customer_id=? AND b.status != 'cancelled' " +
                 "ORDER BY b.start_date DESC";

    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, customerId);
    ps.setInt(2, customerId);
    ResultSet rs = ps.executeQuery();
%>

<h2>My Bookings</h2>
<table border="1">
    <tr>
        <th>Service</th>
        <th>Start Date</th>
        <th>End Date</th>
        <th>Status</th>
        <th>Action</th>
    </tr>

<%
    while(rs.next()) {
        int bookingId = rs.getInt("booking_id");
        int serviceId = rs.getInt("service_id");
        String serviceName = rs.getString("service_name");
        LocalDate startDate = rs.getDate("start_date").toLocalDate();
        LocalDate endDate = rs.getDate("end_date").toLocalDate();
        String status = rs.getString("status");
        boolean feedbackExists = rs.getBoolean("feedback_exists");
%>
    <tr>
        <td><%= serviceName %></td>
        <td><%= startDate %></td>
        <td><%= endDate %></td>
        <td><%= status %></td>
        <td>
            <% if("pending".equalsIgnoreCase(status)) { %>
                <form action="model/updateBookingStatus.jsp" method="post" style="display:inline;">
                    <input type="hidden" name="bookingId" value="<%= bookingId %>">
                    <input type="hidden" name="action" value="pay">
                    <input type="submit" value="Pay" class="btn-pay">
                </form>
                <form action="model/updateBookingStatus.jsp" method="post" style="display:inline;">
                    <input type="hidden" name="bookingId" value="<%= bookingId %>">
                    <input type="hidden" name="action" value="cancel">
                    <input type="submit" value="Cancel" class="btn-cancel">
                </form>
            <% } else if("confirmed".equalsIgnoreCase(status)) { %>
                <form action="model/updateBookingStatus.jsp" method="post" style="display:inline;">
                    <input type="hidden" name="bookingId" value="<%= bookingId %>">
                    <input type="hidden" name="action" value="cancel">
                    <input type="submit" value="Cancel" class="btn-cancel">
                </form>
            <% } else if("completed".equalsIgnoreCase(status)) { %>
                <% if(feedbackExists) { %>
                    <span>Feedback submitted</span>
                <% } else { %>
                    <form action="../feedback/feedback.jsp" method="post" style="display:inline;">
                        <input type="hidden" name="bookingId" value="<%= bookingId %>">
                        <input type="hidden" name="serviceId" value="<%= serviceId %>">
                        <input type="submit" value="Leave Feedback" class="btn-feedback">
                    </form>
                <% } %>
            <% } else { %>
                <span>Feedback submitted</span>
            <% } %>
        </td>
    </tr>
<%
    } // end while
    rs.close();
    ps.close();
    conn.close();
} catch(Exception e) {
    out.println("<p>Database error: " + e.getMessage() + "</p>");
}
%>
</table>

<%@ include file="../footer.jsp" %>
