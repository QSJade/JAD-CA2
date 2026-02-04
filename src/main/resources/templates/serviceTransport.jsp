<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Transportation Assistance</title>
<link rel="stylesheet" href="css/style.css">
</head>

<body>
<%@ include file="header.jsp" %>
<%
Integer loggedInCustomerId = (Integer) session.getAttribute("sessCustomerId");
Integer serviceId = Integer.parseInt(request.getParameter("serviceId"));
int bookPackageCounter = 1; // unique packageId for booking URL
%>



<!-- HEADER -->
<div class="hero-section">
    <div class="hero-overlay">
 	    <h1 class="service-main-title">Transportation Assistance</h1>
        <div class="hero-title">Safe & Convenient Transportation Assistance</div>
        <div class="hero-desc">
            Helping seniors get to medical appointments, errands, and social activities with comfort and ease.
        </div>
    </div>
</div>


<!-- PACKAGES -->
<div class="packages-container">

    <!-- Gold Package -->
    <div class="package-section gold">
        <h2>Gold Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>Full-Day Transport</h3>
                <p>Unlimited rides for appointments and activities throughout the day.</p>
            </div>
            <div class="service-card">
                <h3>Priority Scheduling</h3>
                <p>Guaranteed ride availability and flexible timing.</p>
            </div>
            <div class="service-card">
                <h3>Escort Assistance</h3>
                <p>Staff assists the senior during boarding and alighting.</p>
            </div>
            <h3>Price/day: $80</h3>
        </div>
        <a href="booking/createBooking.jsp?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

    <!-- Silver Package -->
    <div class="package-section silver">
        <h2>Silver Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>Half-Day Transport</h3>
                <p>Morning or afternoon rides for essential appointments.</p>
            </div>
            <div class="service-card">
                <h3>Standard Scheduling</h3>
                <p>Ride requests accommodated with moderate flexibility.</p>
            </div>
            <div class="service-card">
                <h3>Assistance as Needed</h3>
                <p>Staff available if the senior requires help boarding.</p>
            </div>
            <h3>Price/day: $60</h3>
        </div>
        <a href="booking/createBooking.jsp?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

    <!-- Bronze Package -->
    <div class="package-section bronze">
        <h2>Bronze Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>Single Ride</h3>
                <p>One essential ride per day to appointments or errands.</p>
            </div>
            <div class="service-card">
                <h3>Basic Scheduling</h3>
                <p>Pre-scheduled ride at a fixed time.</p>
            </div>
            <div class="service-card">
                <h3>Minimal Assistance</h3>
                <p>Staff assist when necessary.</p>
            </div>
            <h3>Price/day: $40</h3>
        </div>
        <a href="booking/createBooking.jsp?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

</div>

<!-- REVIEWS -->
<div class="reviews-section">
    <h2 class="reviews-header">What Our Customers Say</h2>

    <div class="reviews-container">
    <%
    try {
        Class.forName("org.postgresql.Driver");
        String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
        Connection conn = DriverManager.getConnection(connURL);

        String sql = "SELECT * FROM get_feedback_by_service(?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, serviceId);
        ResultSet rs = ps.executeQuery();

        boolean hasFeedback = false;
        while(rs.next()) {
            hasFeedback = true;
            int feedbackId = rs.getInt("feedback_id");
            int rating = rs.getInt("rating");
            String stars = "★★★★★".substring(0, rating) + "☆☆☆☆☆".substring(rating); // make star ratings first index to rating then fill in the rest with blank stars
            int feedbackCustomerId = rs.getInt("customer_id");
            java.sql.Timestamp ts = rs.getTimestamp("created_at");
            String dateOnly = ts.toLocalDateTime().toLocalDate().toString();            
    %>

        <div class="review-card">
            <div class="review-title"><%= stars %></div>
            <div class="review-text">"<%= rs.getString("comments") %>"</div>
            <div class="review-date"><%= dateOnly %></div>

            <%
            if(loggedInCustomerId != null && feedbackCustomerId == loggedInCustomerId) {
            %>
		<div class="feedback-buttons">
		    <a href="feedback/updateFeedback.jsp?feedbackId=<%= feedbackId %>&serviceId=<%= serviceId %>" class="update-btn">Update</a>
		    <a href="feedback/model/deleteFeedbackQuery.jsp?feedbackId=<%= feedbackId %>&serviceId=<%= serviceId %>" 
		       class="delete-btn" onclick="return confirm('Are you sure you want to delete this feedback?');">Delete</a>
		</div>
            <%
            }
            %>
        </div>

    <%
        }

        if(!hasFeedback) {
    %>
        <p>No feedback yet. Be the first to share your experience!</p>
    <%
        }
        conn.close();
    } catch(Exception e) {
        out.println("Error loading feedback: " + e);
    }
    %>
    </div>

    
</div>

<%@ include file="footer.jsp" %>
</body>
</html>
