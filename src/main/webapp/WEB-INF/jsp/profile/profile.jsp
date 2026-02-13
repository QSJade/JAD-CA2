<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*" %>
<%@ include file="../header.jsp" %>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<title>My Profile</title>
</head>
<body>

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}

// Get error and success messages from request
String errCode = request.getParameter("errCode");
String success = request.getParameter("success");
%>

<div class="profile-container">

<%
try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    // ===== LOAD USER INFO =====
    String username = "", email = "", address = "";
    PreparedStatement psUser = conn.prepareStatement("SELECT name, email, address FROM customers WHERE customer_id=?");
    psUser.setInt(1, customerId);
    ResultSet rsUser = psUser.executeQuery();
    if (rsUser.next()) {
        username = rsUser.getString("name");
        email = rsUser.getString("email");
        address = rsUser.getString("address") != null ? rsUser.getString("address") : "";
    }
    rsUser.close();
    psUser.close();
%>

    <h1>My Profile</h1>
    
    <!-- ===== PROFILE MESSAGES ===== -->
    <% if (success != null) { %>
        <% if ("updated".equals(success)) { %>
            <div class="message success">✓ Profile updated successfully!</div>
        <% } else if ("healthUpdated".equals(success)) { %>
            <div class="message success">✓ Health profile updated successfully!</div>
        <% } %>
    <% } %>

    <% if (errCode != null) { %>
        <% if ("updateFail".equals(errCode)) { %>
            <div class="message error">✗ Failed to update profile. Please try again.</div>
        <% } else if ("deleteFail".equals(errCode)) { %>
            <div class="message error">✗ Failed to delete account. Please try again.</div>
        <% } else if ("healthUpdateFail".equals(errCode)) { %>
            <div class="message error">✗ Failed to update health profile. Please try again.</div>
        <% } %>
    <% } %>
    
    <!-- ===== PROFILE FORM SECTION ===== -->
    <div class="form-wrapper">
        <form action="${pageContext.request.contextPath}/profile/update" method="post" class="profile-form">
            <div class="form-row">
                <label for="username">Username:</label>
                <input type="text" name="username" id="username" value="<%= username %>" required>
            </div>
            <div class="form-row">
                <label for="email">Email:</label>
                <input type="email" name="email" id="email" value="<%= email %>" readonly>
            </div>
            <div class="form-row">
                <label for="address">Address:</label>
                <input type="text" name="address" id="address" value="<%= address %>" required>
            </div>
            <div class="form-row">
                <label for="password">Password:</label>
                <input type="password" name="password" id="password" placeholder="Leave blank to keep current">
            </div>
            <div class="button-row">
                <input type="submit" value="Update Profile" class="btn-update">
            </div>
        </form>

        <form action="${pageContext.request.contextPath}/profile/delete" method="post" 
              onsubmit="return confirm('Are you sure you want to delete your account? This action cannot be undone.');" 
              class="delete-form">
            <div class="button-row">
                <input type="submit" value="Delete Profile" class="btn-delete">
            </div>
        </form>
        
        <!-- ===== HEALTH PROFILE BUTTON ===== -->
        <div class="health-section">
            <h3>Health & Emergency Information</h3>
            <p class="health-description">Manage your health conditions, allergies, and emergency contacts</p>
            <a href="${pageContext.request.contextPath}/profile/health" class="btn-outline">
                Edit Health Profile
            </a>
        </div>
    </div>

    <h2>My Bookings</h2>
    
    <!-- ===== BOOKING MESSAGES ===== -->
    <% if (success != null) { %>
        <% if ("paymentConfirmed".equals(success)) { %>
            <div class="message success">✓ Payment confirmed! Your booking is now confirmed.</div>
        <% } else if ("bookingCancelled".equals(success)) { %>
            <div class="message success">✓ Booking cancelled successfully.</div>
        <% } %>
    <% } %>

    <% if (errCode != null) { %>
        <% if ("paymentFailed".equals(errCode)) { %>
            <div class="message error">✗ Payment failed. Please try again.</div>
        <% } else if ("cancelFailed".equals(errCode)) { %>
            <div class="message error">✗ Failed to cancel booking. Please try again.</div>
        <% } else if ("bookingNotFound".equals(errCode)) { %>
            <div class="message error">✗ Booking not found.</div>
        <% } else if ("unauthorized".equals(errCode)) { %>
            <div class="message error">✗ You are not authorized to perform this action.</div>
        <% } else if ("cannotCancel".equals(errCode)) { %>
            <div class="message error">✗ This booking cannot be cancelled.</div>
        <% } else if ("cannotCancelPaid".equals(errCode)) { %>
            <div class="message error">✗ Cannot cancel a paid booking. Please contact customer service for refunds.</div>
        <% } %>
    <% } %>

<%
    // ===== UPDATE COMPLETED BOOKINGS - Fix: Update confirmed bookings that have ended =====
    String updateCompletedSQL = "UPDATE bookings SET status='completed' WHERE customer_id=? AND status='confirmed' AND end_date < CURRENT_DATE";
    PreparedStatement psUpdate = conn.prepareStatement(updateCompletedSQL);
    psUpdate.setInt(1, customerId);
    int updatedCount = psUpdate.executeUpdate();
    psUpdate.close();
    
    // Log if any bookings were updated (optional)
    if (updatedCount > 0) {
        System.out.println("Updated " + updatedCount + " bookings to completed for customer " + customerId);
    }

    // ===== GET ALL ACTIVE BOOKINGS =====
    String sql = "SELECT b.booking_id, b.service_id, s.service_name, b.start_date, b.end_date, b.status, " +
                 "       CASE WHEN f.booking_id IS NOT NULL THEN TRUE ELSE FALSE END AS feedback_exists " +
                 "FROM bookings b " +
                 "JOIN services s ON b.service_id = s.service_id " +
                 "LEFT JOIN feedbacks f ON b.booking_id = f.booking_id " +
                 "WHERE b.customer_id=? AND b.status != 'cancelled' " +
                 "ORDER BY b.start_date DESC";

    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, customerId);
    ResultSet rs = ps.executeQuery();
    
    boolean hasBookings = false;
    LocalDate today = LocalDate.now();
%>

    <table class="bookings-table">
        <thead>
            <tr>
                <th>Service</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>

<%
    while(rs.next()) {
        hasBookings = true;
        int bookingId = rs.getInt("booking_id");
        int serviceId = rs.getInt("service_id");
        String serviceName = rs.getString("service_name");
        LocalDate startDate = rs.getDate("start_date").toLocalDate();
        LocalDate endDate = rs.getDate("end_date").toLocalDate();
        String status = rs.getString("status");
        boolean feedbackExists = rs.getBoolean("feedback_exists");
        
        String statusClass = "";
        String statusText = status.toUpperCase();
        
        if ("pending".equalsIgnoreCase(status)) {
            statusClass = "status-pending";
        } else if ("confirmed".equalsIgnoreCase(status)) {
            statusClass = "status-confirmed";
        } else if ("completed".equalsIgnoreCase(status)) {
            statusClass = "status-completed";
        } else {
            statusClass = "status-cancelled";
            statusText = "CANCELLED";
        }
        
        // Check if booking has ended (end date is before today)
        boolean hasEnded = endDate.isBefore(today);
%>
        <tr>
            <td><strong><%= serviceName %></strong></td>
            <td><%= startDate %></td>
            <td><%= endDate %></td>
            <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
            <td>
                <% if("pending".equalsIgnoreCase(status)) { %>
                    <%-- PENDING - Not paid yet --%>
                    <button onclick="payWithStripe(<%= bookingId %>, <%= serviceId %>, '<%= startDate %>', '<%= endDate %>')" class="btn-pay">
                        Pay Now
                    </button>
                    <form action="${pageContext.request.contextPath}/bookings/<%= bookingId %>/cancel" method="post" style="display:inline;">
                        <input type="submit" value="Cancel" class="btn-cancel" onclick="return confirm('Are you sure you want to cancel this booking?');">
                    </form>
                    
                <% } else if("confirmed".equalsIgnoreCase(status)) { %>
                    <%-- CONFIRMED - Paid but not yet completed --%>
                    <% if(hasEnded) { %>
                        <%-- Booking has ended - Can leave feedback --%>
                        <% if(feedbackExists) { %>
                            <span class="feedback-submitted">✓ Feedback Submitted</span>
                        <% } else { %>
                            <form action="${pageContext.request.contextPath}/feedback" method="get" style="display:inline;">
                                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                                <input type="hidden" name="serviceId" value="<%= serviceId %>">
                                <input type="submit" value="Leave Feedback" class="btn-feedback">
                            </form>
                        <% } %>
                    <% } else { %>
                        <%-- Booking still active --%>
                        <span class="paid-badge">✓ Paid</span>
                    <% } %>
                    
                <% } else if("completed".equalsIgnoreCase(status)) { %>
                    <%-- COMPLETED - Booking is finished --%>
                    <% if(feedbackExists) { %>
                        <span class="feedback-submitted">✓ Feedback Submitted</span>
                    <% } else { %>
                        <form action="${pageContext.request.contextPath}/feedback" method="get" style="display:inline;">
                            <input type="hidden" name="bookingId" value="<%= bookingId %>">
                            <input type="hidden" name="serviceId" value="<%= serviceId %>">
                            <input type="submit" value="Leave Feedback" class="btn-feedback">
                        </form>
                    <% } %>
                <% } %>
            </td>
        </tr>
<%
    }
    rs.close();
    ps.close();
    conn.close();
    
    if (!hasBookings) {
%>
        <tr>
            <td colspan="5" class="no-bookings">
                <p>You have no bookings yet.</p>
                <a href="${pageContext.request.contextPath}/serviceDetails" class="btn-outline">
                    Browse Our Services
                </a>
            </td>
        </tr>
<%
    }
%>
        </tbody>
    </table>

<%
} catch(Exception e) {
    out.println("<div class='message error'>");
    out.println("<strong>Database Error:</strong> " + e.getMessage());
    out.println("</div>");
    e.printStackTrace();
}
%>

</div>

<!-- Stripe.js -->
<script src="https://js.stripe.com/v3/"></script>
<script>
const stripe = Stripe("pk_test_51SsDLV7JAQOUwt4TDGl0QVyxrTkZgF1BU7kxqf8VXrz2OQh03mQ2igl4l4cLa7jJXeoL0VcdPnfEBaD1BXzyrGvQ001gVHC5iT");

async function payWithStripe(bookingId, serviceId, startDate, endDate) {
    if (!confirm('Proceed to payment for this booking?')) {
        return;
    }
    
    try {
        const response = await fetch('${pageContext.request.contextPath}/stripe/create-checkout-session', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                bookingId: bookingId,
                serviceId: serviceId,
                startDate: startDate,
                endDate: endDate
            })
        });
        
        if (!response.ok) {
            throw new Error('Failed to create checkout session');
        }
        
        const data = await response.json();
        
        if (!data.id) {
            throw new Error('No session ID returned');
        }
        
        const result = await stripe.redirectToCheckout({
            sessionId: data.id
        });
        
        if (result.error) {
            throw new Error(result.error.message);
        }
        
    } catch (error) {
        alert('Payment failed: ' + error.message);
    }
}
</script>

<%@ include file="../footer.jsp" %>
</body>
</html>