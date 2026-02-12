<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<title>Update Feedback</title>

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
</style>
</head>
<body>
<%@ include file="../header.jsp" %>

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
String feedbackIdStr = request.getParameter("feedbackId");
String serviceIdStr = request.getParameter("serviceId");

// Check if logged in
if(customerId == null) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}

// Validate feedbackId
if(feedbackIdStr == null || feedbackIdStr.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/profile?errCode=missingId");
    return;
}

int feedbackId = Integer.parseInt(feedbackIdStr);
int serviceId = 0;
if(serviceIdStr != null && !serviceIdStr.isEmpty()) {
    serviceId = Integer.parseInt(serviceIdStr);
}

// Check for invalid input
String errCode = request.getParameter("errCode");
if (errCode != null && errCode.equals("ratingFail")) {
    out.println("<p style='color: red; text-align: center;'>Rating must be between 1 and 5.</p>");
} else if (errCode != null && errCode.equals("commentEmpty")) {
    out.println("<p style='color: red; text-align: center;'>Comments cannot be empty.</p>");
} else if (errCode != null && errCode.equals("updateFail")) {
    out.println("<p style='color: red; text-align: center;'>Feedback not update. Please try again.</p>");
}

// Fetch existing feedback data
String existingComments = "";
int existingRating = 0;

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String sql = "SELECT rating, comments, service_id FROM feedbacks WHERE feedback_id = ? AND customer_id = ?";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, feedbackId);
    ps.setInt(2, customerId);
    ResultSet rs = ps.executeQuery();
    
    if(rs.next()) {
        existingRating = rs.getInt("rating");
        existingComments = rs.getString("comments");
        serviceId = rs.getInt("service_id");
    } else {
        conn.close();
        response.sendRedirect(request.getContextPath() + "/serviceDetails?errCode=feedbackNotFound");
        return;
    }
    conn.close();
} catch(Exception e) {
    out.println("<p style='color: red; text-align: center;'>Error loading feedback: " + e.getMessage() + "</p>");
    return;
}
%>

<h2>Update Your Feedback</h2>

<div class="form-wrapper">
    <form action="${pageContext.request.contextPath}/feedback/update" method="post" class="profile-form">
        <!-- Hidden inputs -->
        <input type="hidden" name="feedbackId" value="<%= feedbackId %>">
        <input type="hidden" name="serviceId" value="<%= serviceId %>">
        <input type="hidden" name="rating" id="ratingInput" value="<%= existingRating %>">
        
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
            <textarea name="comments" id="comments" rows="5" required><%= existingComments %></textarea>
        </div>

        <div class="button-row">
            <button type="submit" class="btn-update">Update Feedback</button>
            <a href="${pageContext.request.contextPath}/serviceDetails?serviceId=<%= serviceId %>" class="btn-outline">Cancel</a>
        </div>
    </form>
</div>

<script>
// Highlight existing rating on page load
$(document).ready(function() {
    var existingRating = <%= existingRating %>;
    if (existingRating > 0) {
        $('.star-' + existingRating).addClass('active');
        $('.stars span').addClass('active');
        $('#ratingInput').val(existingRating);
    }
});

// Click handler for stars
$('.stars a').on('click', function(e) {
    e.preventDefault();
    $('.stars a').removeClass('active');
    $(this).addClass('active');
    $('.stars span').addClass('active');
    var rating = $(this).text();
    $('#ratingInput').val(rating);
});
</script>

<%@ include file="../footer.jsp" %>
</body>
</html>