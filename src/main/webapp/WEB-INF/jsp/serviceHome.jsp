<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>In-Home Care</title>
<link rel="stylesheet" href="css/style.css">
</head>

<body>
<%@ include file="header.jsp" %>
<%
Integer loggedInCustomerId = (Integer) session.getAttribute("sessCustomerId");
Integer serviceId = Integer.parseInt(request.getParameter("serviceId"));
int bookPackageCounter = 1; // unique packageId for booking URL
%>

<!-- HEADER  -->
<div class="hero-section">
    <div class="hero-overlay">
    	<h1 class="service-main-title">In-Home Care</h1>
        <div class="hero-title">Reliable At-Home Care & Cleaning Services</div>
        <div class="hero-desc">
            Compassionate caregivers providing daily support, home upkeep, and peace of mind for your loved ones.
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
                <h3>Full Day Care</h3>
                <p>Comprehensive care throughout the day.</p>
            </div>
            <div class="service-card">
                <h3>Cooking & Family Check-ins</h3>
                <p>Meal preparation and regular updates to family members.</p>
            </div>
            <div class="service-card">
                <h3>House Cleaning & Tidying</h3>
                <p>Full home upkeep included for peace of mind.</p>
            </div>
            <div class="service-card">
                <h3>Enrichment Activities</h3>
                <p>Engaging activities to enhance cognitive and emotional wellbeing.</p>
            </div>
            <h3>Price/day: $200</h3>
        </div>
        <a href="${pageContext.request.contextPath}/booking/createBooking?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

    <!-- Silver Package -->
    <div class="package-section silver">
        <h2>Silver Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>Half Day Care</h3>
                <p>Care for morning or afternoon sessions.</p>
            </div>
            <div class="service-card">
                <h3>Family Check-ins</h3>
                <p>Check-ins with family if needed.</p>
            </div>
            <div class="service-card">
                <h3>House Cleaning</h3>
                <p>Light cleaning services included.</p>
            </div>
            <div class="service-card">
                <h3>Enrichment Activities</h3>
                <p>Fun activities to keep seniors active and engaged.</p>
            </div>
            <h3>Price/day: $150</h3>
        </div>
        <a href="${pageContext.request.contextPath}/booking/createBooking?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

    <!-- Bronze Package -->
    <div class="package-section bronze">
        <h2>Bronze Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>3 Hour Care Session</h3>
                <p>Short but focused care session.</p>
            </div>
            <div class="service-card">
                <h3>Wellness Report</h3>
                <p>Report after each session.</p>
            </div>
            <div class="service-card">
                <h3>House Tidying</h3>
                <p>Basic tidying included.</p>
            </div>
            <div class="service-card">
                <h3>Enrichment Activities</h3>
                <p>Simple cognitive exercises and social engagement.</p>
            </div>
            <h3>Price/day: $100</h3>
        </div>
        <a href="${pageContext.request.contextPath}/booking/createBooking?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

</div>


<!-- REVIEWS  -->
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
            // Change date formatting
            java.sql.Timestamp ts = rs.getTimestamp("created_at");
            String dateOnly = ts.toLocalDateTime().toLocalDate().toString();
    %>

        <div class="review-card">
            <div class="review-title"><%= stars %></div>
            <div class="review-text">"<%= rs.getString("comments") %>"</div>
            <div class="review-date"><%= dateOnly %></div>
            
    <%
            // Show update/delete only for the logged in user's feedback
            if(loggedInCustomerId != null && feedbackCustomerId == loggedInCustomerId) {
     %>
		<div class="feedback-buttons">
			<a href="${pageContext.request.contextPath}/feedback/update?feedbackId=<%= feedbackId %>&serviceId=<%= serviceId %>" class="update-btn">Update</a>
			<a href="${pageContext.request.contextPath}/feedback/delete?feedbackId=<%= feedbackId %>&serviceId=<%= serviceId %>" 
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
