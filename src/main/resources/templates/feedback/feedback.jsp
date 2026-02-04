<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="../css/style.css">
<title>Star Rating</title>

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
if(customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}


Integer bookingId = null;
Integer serviceId = null;

try {
    bookingId = Integer.parseInt(request.getParameter("bookingId"));
    serviceId = Integer.parseInt(request.getParameter("serviceId"));
} catch (Exception e) {
    response.sendRedirect("../profile/profile.jsp?errCode=missingId");
    return;
}


String errCode = request.getParameter("errCode");
if (errCode != null && errCode.equals("insertFail")) {
    out.println("<p style='color: red;'>One of your values are wrong. Please try again.</p>");
}
//Check for invalid input
else if (errCode != null && errCode.equals("ratingFail")) {
 out.println("<p style='color: red;'>Rating must be more than 1 and less than 5.</p>");
}
// Duplicate feedback error
else if (errCode != null && errCode.equals("alreadySubmitted")) {
    out.println("<p style='color:red;'>You have already submitted feedback for this booking.</p>");
}

// Check if user can leave feedback
boolean canLeaveFeedback = false;
try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    String sql = "SELECT 1 FROM bookings WHERE customer_id = ? AND service_id = ? AND status='completed' AND end_date < CURRENT_DATE";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, customerId);
    ps.setInt(2, serviceId);
    ResultSet rs = ps.executeQuery();
    if(rs.next()) canLeaveFeedback = true;

 // Prevent duplicate feedbacks
    String sqlCheck = "SELECT 1 FROM feedbacks WHERE booking_id = ?";
    PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
    psCheck.setInt(1, bookingId);
    ResultSet rsCheck = psCheck.executeQuery();

    if (rsCheck.next()) {
        response.sendRedirect("feedback.jsp?errCode=alreadySubmitted");
        return;
    }

    conn.close();
} catch(Exception e) {
    out.println("Error: " + e);
}
%>

<h2>Rate Your Experience</h2>

<%
if(canLeaveFeedback) {
%>

<form action="model/createFeedbackQuery.jsp" method="post" class="form-wrapper">
    <!-- hidden inputs -->
    <input type="hidden" name="customerId" value="<%= customerId %>">
    <input type="hidden" name="serviceId" value="<%= serviceId %>">
    <input type="hidden" name="bookingId" value="<%= bookingId %>">
    <input type="hidden" name="rating" id="ratingInput" value="0">

    <p class="stars">
        <span>
          <a class="star-1" href="#">1</a>
          <a class="star-2" href="#">2</a>
          <a class="star-3" href="#">3</a>
          <a class="star-4" href="#">4</a>
          <a class="star-5" href="#">5</a>
        </span>
    </p>

    <label for="comments">Comments:</label><br>
    <textarea name="comments" required></textarea><br><br>

    <button type="submit">Submit Feedback</button>
</form>

<script>
$('.stars a').on('click', function(e) {
    e.preventDefault(); // stops the star clicking to reload the page (behaviour of <a> tag)
    $('.stars span, .stars a').removeClass('active');
    $(this).addClass('active');
    $('.stars span').addClass('active');
    var rating = $(this).text();
    $('#ratingInput').val(rating); // set hidden input for form
});
</script>

<%
} else {
%>
<p>You can leave feedback only after completing a service.</p>
<%
}
%>

<%@ include file="../footer.jsp" %>
</body>
</html>
