<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="../css/style.css">
<title>Update Feedback</title>

<!-- jQuery for stars -->
<!--  all for pretty looking stars.. -->
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
int feedbackId = Integer.parseInt(request.getParameter("feedbackId"));
Integer customerId = (Integer) session.getAttribute("sessCustomerId");

//Check if logged in
if(customerId == null) {
 response.sendRedirect("../login.jsp?errCode=notLoggedIn");
 return;
}
// Check for invalid input
String errCode = request.getParameter("errCode");
if (errCode != null && errCode.equals("ratingFail")) {
    out.println("<p style='color: red;'>Rating must be more than 1 and less than 5.</p>");
}

//Fetch existing feedback data
String existingComments = "";
int existingRating = 0;

try {
 Class.forName("org.postgresql.Driver");
 String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
 Connection conn = DriverManager.getConnection(connURL);

 String sql = "SELECT rating, comments FROM feedbacks WHERE feedback_id = ? AND customer_id = ?";
 PreparedStatement ps = conn.prepareStatement(sql);
 ps.setInt(1, feedbackId);
 ps.setInt(2, customerId);
 ResultSet rs = ps.executeQuery();
 
 if(rs.next()) {
     existingRating = rs.getInt("rating");
     existingComments = rs.getString("comments");
 } else {
     response.sendRedirect("../serviceDetails.jsp?errCode=feedbackNotFound");
     return;
 }
 conn.close();
} catch(Exception e) {
 out.println("Error loading feedback: " + e);
 return;
}
%>

<h2>Update Your Feedback</h2>
<form action="model/updateFeedbackQuery.jsp" method="post" class="form-wrapper">
    <!-- hidden inputs -->
    <input type="hidden" name="feedbackId" value="<%= feedbackId %>">
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
    <textarea name="comments" required><%= existingComments %></textarea><br><br>

    <button type="submit">Update Feedback</button>
</form>

<script>
// Highlight existing rating on page load
$(document).ready(function() {
    if (<%= existingRating %> > 0) {
        $('.star-' + <%= existingRating %>).addClass('active');
        $('.stars span').addClass('active');
        $('#ratingInput').val(<%= existingRating %>);
    }
});

// Click handler
$('.stars a').on('click', function(e) {
    e.preventDefault();
    $('.stars a').removeClass('active');
    $(this).addClass('active');
    $('.stars span').addClass('active');
    $('#ratingInput').val($(this).text());
});
</script>


<%@ include file="../footer.jsp" %>
</body>
</html>
