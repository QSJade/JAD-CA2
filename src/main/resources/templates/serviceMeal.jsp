<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Meal Support</title>
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
   		 <h1 class="service-main-title">Meal Support</h1>
        <div class="hero-title">Fresh and Healthy Meals Delivered</div>
        <div class="hero-desc">Nutritious meals prepared with care for your loved ones.</div>
    </div>
</div>


<!-- PACKAGES -->
<div class="packages-container">

    <!-- Gold Package -->
    <div class="package-section gold">
        <h2>Gold Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>Full-Day Meal Delivery</h3>
                <p>Breakfast, lunch, snacks and dinner prepared and delivered.</p>
            </div>
            <div class="service-card">
                <h3>Personalized Meal Plan</h3>
                <p>Customized meals according to dietary needs and preferences.</p>
            </div>
            <div class="service-card">
                <h3>Family Updates</h3>
                <p>Notifications to family members on meal plans and nutrition.</p>
            </div>
            <div class="service-card">
                <h3>Enrichment Activity</h3>
                <p>Cooking tips and interactive meal ideas to keep seniors engaged.</p>
            </div>
            <h3>Price/day: $40</h3>
        </div>
        <a href="booking/createBooking.jsp?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

    <!-- Silver Package -->
    <div class="package-section silver">
        <h2>Silver Package</h2>
        <div class="services-container">
            <div class="service-card">
                <h3>Half-Day Meal Delivery</h3>
                <p>Lunch and dinner prepared and delivered.</p>
            </div>
            <div class="service-card">
                <h3>Standard Meal Plan</h3>
                <p>Healthy meal options with balanced nutrition.</p>
            </div>
            <div class="service-card">
                <h3>Family Notifications</h3>
                <p>Meal updates to family members.</p>
            </div>
            <div class="service-card">
                <h3>Enrichment Activity</h3>
                <p>Simple meal prep tips and interactive ideas.</p>
            </div>
            <h3>Price/day: $30</h3>
        </div>
        <a href="booking/createBooking.jsp?packageId=<%= bookPackageCounter++ %>&serviceId=<%= serviceId %>" class="book-btn">Book Now</a>
    </div>

    <!-- Bronze Package -->
    <div class="package-section bronze">
        <h2>Bronze Package</h2>
        <div class="services-container bronze">
            <div class="service-card">
                <h3>Single Meal Delivery</h3>
                <p>One meal delivered per day (lunch or dinner).</p>
            </div>
            <div class="service-card">
                <h3>Basic Meal Plan</h3>
                <p>Nutritious simple meal options.</p>
            </div>
            <div class="service-card">
                <h3>Meal Feedback Report</h3>
                <p>Short report after each meal delivery.</p>
            </div>
            <div class="service-card">
                <h3>Enrichment Activity</h3>
                <p>Tips on healthy eating activities.</p>
            </div>
            <h3>Price/day: $20</h3>
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
            // Change date formatting
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
