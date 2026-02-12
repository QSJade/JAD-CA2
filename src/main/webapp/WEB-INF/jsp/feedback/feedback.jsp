<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<title>Rate Your Experience</title>

<!-- jQuery for stars -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    .stars a { display: inline-block; padding-right: 4px; text-decoration: none; margin: 0; }
    .stars a:after { font-size: 18px; font-family: 'FontAwesome', serif; content: "\f005"; color: #9e9e9e ; }
    span { font-size: 0; }
    .stars a:hover~a:after { color: #9e9e9e  !important; }
    span.active a.active~a:after { color: #9e9e9e ; }
    span:hover a:after { color: #FFC107 !important; }
    span.active a:after, .stars a.active:after { color: #FFC107; }
    .error-message { 
        color: red; 
        text-align: center; 
        margin: 10px 0;
        padding: 10px;
        background-color: #ffeeee;
        border-radius: 5px;
    }
    .success-message {
        color: green;
        text-align: center;
        margin: 10px 0;
        padding: 10px;
        background-color: #eeffee;
        border-radius: 5px;
    }
</style>
</head>
<body>
<%@ include file="../header.jsp" %>

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if(customerId == null) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}

Integer bookingId = null;
Integer serviceId = null;

try {
    bookingId = Integer.parseInt(request.getParameter("bookingId"));
    serviceId = Integer.parseInt(request.getParameter("serviceId"));
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/profile?errCode=missingId");
    return;
}

// Error and success message handling
String errCode = request.getParameter("errCode");
if (errCode != null) {
    out.println("<div class='error-message'>");
    if (errCode.equals("insertFail")) {
        out.println("Failed to submit feedback. Please try again.");
    } else if (errCode.equals("ratingFail")) {
        out.println("Rating must be between 1 and 5.");
    } else if (errCode.equals("alreadySubmitted")) {
        out.println("You have already submitted feedback for this booking.");
    } else if (errCode.equals("missingValues")) {
        out.println("Please fill in all fields.");
    } else if (errCode.equals("invalidNumber")) {
        out.println("Invalid input. Please try again.");
    }
    out.println("</div>");
}

// Check if user can leave feedback
boolean canLeaveFeedback = false;
boolean alreadySubmitted = false;

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    // Check if booking is completed
    String sql = "SELECT 1 FROM bookings WHERE customer_id = ? AND service_id = ? AND status='completed' AND end_date < CURRENT_DATE";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, customerId);
    ps.setInt(2, serviceId);
    ResultSet rs = ps.executeQuery();
    canLeaveFeedback = rs.next();
    rs.close();
    ps.close();

    // Check for duplicate feedback
    String sqlCheck = "SELECT 1 FROM feedbacks WHERE booking_id = ?";
    PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
    psCheck.setInt(1, bookingId);
    ResultSet rsCheck = psCheck.executeQuery();
    alreadySubmitted = rsCheck.next();
    rsCheck.close();
    psCheck.close();
    
    conn.close();
} catch(Exception e) {
    out.println("<div class='error-message'>Error loading feedback: " + e.getMessage() + "</div>");
}

if (alreadySubmitted) {
%>
    <div class="error-message">
        You have already submitted feedback for this booking.
    </div>
    <div style="text-align: center; margin-top: 20px;">
        <a href="${pageContext.request.contextPath}/serviceDetails?serviceId=<%= serviceId %>" class="btn-outline">Back to Service</a>
    </div>
<%
} else if(canLeaveFeedback) {
%>
    <h2 style="text-align: center; margin-top: 30px;">Rate Your Experience</h2>
    
    <div class="form-wrapper">
        <form action="${pageContext.request.contextPath}/feedback/create" method="post" class="profile-form">
            <!-- Hidden inputs -->
            <input type="hidden" name="customerId" value="<%= customerId %>">
            <input type="hidden" name="serviceId" value="<%= serviceId %>">
            <input type="hidden" name="bookingId" value="<%= bookingId %>">
            <input type="hidden" name="rating" id="ratingInput" value="0">

            <div class="form-row">
                <label>Your Rating:</label>
                <div class="stars">
                    <span>
                        <a class="star-1" href="#">1</a>
                        <a class="star-2" href="#">2</a>
                        <a class="star-3" href="#">3</a>
                        <a class="star-4" href="#">4</a>
                        <a class="star-5" href="#">5</a>
                    </span>
                </div>
            </div>

            <div class="form-row">
                <label for="comments">Comments:</label>
                <textarea name="comments" id="comments" rows="5" required placeholder="Share your experience..."></textarea>
            </div>

            <div class="button-row">
                <button type="submit" class="btn-update">Submit Feedback</button>
                <a href="${pageContext.request.contextPath}/serviceDetails?serviceId=<%= serviceId %>" class="btn-outline">Cancel</a>
            </div>
        </form>
    </div>

    <script>
    $(document).ready(function() {
        $('.stars a').on('click', function(e) {
            e.preventDefault();
            $('.stars a').removeClass('active');
            $(this).addClass('active');
            $('.stars span').addClass('active');
            var rating = $(this).text();
            $('#ratingInput').val(rating);
        });
    });
    </script>

<%
} else {
%>
    <div style="text-align: center; margin-top: 50px;">
        <h3>You can only leave feedback after completing a service.</h3>
        <p style="margin-top: 20px; color: #666;">
            Your booking must be marked as 'completed' and the end date must have passed.
        </p>
        <div style="margin-top: 30px;">
            <a href="${pageContext.request.contextPath}/profile" class="btn-outline">View My Bookings</a>
            <a href="${pageContext.request.contextPath}/serviceDetails" class="btn-outline">Browse Services</a>
        </div>
    </div>
<%
}
%>

<%@ include file="../footer.jsp" %>
</body>
</html>