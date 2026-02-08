<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

// Retrieve form values safely
String customerIdStr = request.getParameter("customerId");
String serviceIdStr  = request.getParameter("serviceId");
String bookingIdStr  = request.getParameter("bookingId");
String ratingStr     = request.getParameter("rating");
String comments      = request.getParameter("comments");

// ===== VALIDATION: Prevent Nulls =====
if (customerIdStr == null || serviceIdStr == null || bookingIdStr == null || 
    ratingStr == null || comments == null ||
    customerIdStr.isEmpty() || serviceIdStr.isEmpty() || bookingIdStr.isEmpty() ||
    ratingStr.isEmpty() || comments.isEmpty()) {

    response.sendRedirect("../feedback.jsp?errCode=missingValues");
    return;
}

int customerId = 0;
int serviceId = 0;
int bookingId = 0;
int rating = 0;

// ===== VALIDATION: Safe Parsing =====
try {
    customerId = Integer.parseInt(customerIdStr);
    serviceId  = Integer.parseInt(serviceIdStr);
    bookingId  = Integer.parseInt(bookingIdStr);
    rating     = Integer.parseInt(ratingStr);
} catch (Exception e) {
    response.sendRedirect("../feedback.jsp?errCode=invalidNumber");
    return;
}

// ===== VALIDATION: rating must be 1–5 =====
if (rating < 1 || rating > 5) {
    response.sendRedirect("../feedback.jsp?errCode=ratingFail");
    return;
}

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);

    // ===== Check for duplicate feedback =====
    String sqlCheck = "SELECT 1 FROM feedbacks WHERE booking_id = ?";
    PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
    psCheck.setInt(1, bookingId);
    ResultSet rsCheck = psCheck.executeQuery();

    if (rsCheck.next()) {
        conn.close();
        response.sendRedirect("../feedback.jsp?errCode=alreadySubmitted");
        return;
    }

    // ===== Insert feedback =====
    String sqlInsert = 
        "INSERT INTO feedbacks (customer_id, service_id, booking_id, rating, comments) " + "VALUES (?, ?, ?, ?, ?)";
    PreparedStatement psInsert = conn.prepareStatement(sqlInsert);
    psInsert.setInt(1, customerId);
    psInsert.setInt(2, serviceId);
    psInsert.setInt(3, bookingId);
    psInsert.setInt(4, rating);
    psInsert.setString(5, comments);

    int rows = psInsert.executeUpdate();
    conn.close();

    if (rows > 0) {
%>
        <script>
            alert('Feedback created successfully!');
            // Redirect back to same service page
            window.location.href = '../../serviceDetails.jsp?serviceId=<%= serviceIdStr %>';
        </script>
<%
    } else {
        response.sendRedirect("../feedback.jsp?errCode=insertFail");
    }

} catch (Exception e) {
    out.println("Error: " + e);
}
%>
